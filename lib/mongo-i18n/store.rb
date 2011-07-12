# encoding: UTF-8
module MongoI18n
  class Store
    attr_reader :collection

    def initialize(collection, options={})
      @collection, @options = collection, options
    end

    def []=(key, value, options = {})
      key = key.to_s
      doc = {:_id => key, :value => value}
      collection.save(doc)
    end

    # alias for read
    def [](key, options=nil)
      if doc = collection.find_one(:_id => key.to_s)
        doc["value"].to_s
      end
    end

    def keys
      keys = []
      collection.find({}, :fields => ["_id"]).each do |row|
        keys.push(row["_id"])
      end
      keys
    end

    # Thankfully borrowed from Jodosha's redis-store
    # https://github.com/jodosha/redis-store/blob/master/lib/i18n/backend/redis.rb
    def available_locales
      self.keys.map { |k| k =~ /\./; $` }.compact.uniq.map(&:to_sym)
    end
  end
end