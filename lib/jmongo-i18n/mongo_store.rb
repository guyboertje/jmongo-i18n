require 'i18n/backend/base'
require 'hashery'

module I18n
  module Backend

    class MongoStore
      module Implementation
        attr_reader :store

        include Base, Flatten

        def initialize(collection, options={})
          @store, @options = collection, options
          @depth = options.fetch(:depth, 1)
        end

        def store_translations(locale, data, options = {})
          escape = options.fetch(:escape, true)
          flatten_to_subtree_depth(locale, data, escape, @depth).each do |key, value|
            key = "#{locale}.#{key}"
            raise "Mongo Store cannot handle procs" if value.kind_of?(Proc)
            if value.kind_of?(Hash) && (old_val = get_value(key)) && old_val.kind_of?(Hash)
              value = old_val.deep_merge!(value)
            end
            unless value.is_a?(Symbol)
              store.update({'_id'=>key},{'_id'=>key,'value'=>value},{:upsert=>true,:safe=>true,:multi=>false})
            end
          end
        end

        def available_locales
          @store.find({}, :fields => ["_id"]).map{ |k| k['_id'] =~ /\./; $` }.compact.uniq.map(&:to_sym)
        end

        def fetch locale, key
          lookup(locale, key)
        end

      #protected

        def lookup(locale, key, scope = [], options = {})
          doc = get_value("#{locale}.#{key}")
          if doc && (value = doc['value'])
            value.is_a?(Hash) ? OpenCascade.new(value.deep_symbolize_keys) : value
          end
        end

      #private

        def get_value(id)
          @store.find_one('_id'=>id)
        end

        def stoppable_flatten_keys(hash, escape, prev_key=nil, &block)
          hash.each_pair do |key, value|
            key = escape_default_separator(key) if escape
            curr_key = [prev_key, key].compact.join(FLATTEN_SEPARATOR).to_sym
            stop = yield curr_key, value
            unless stop
              stoppable_flatten_keys(value, escape, curr_key, &block) if value.is_a?(Hash)
            end
          end
        end

        def flatten_to_subtree_depth(locale,data,escape,depth=1)
          hash = {}
          stoppable_flatten_keys(data,escape) do |key,value|
            if key.to_s.count(FLATTEN_SEPARATOR).succ == depth
              store_link(locale, key, value) if value.is_a?(Symbol)
              hash[key] = value.kind_of?(Hash) ? value.deep_stringify_keys : value
              true
            else
              false
            end
          end
          hash
        end
      end

      include Implementation
    end
  end
end