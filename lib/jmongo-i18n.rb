# encoding: UTF-8

require RUBY_PLATFORM =~ /java/ ? 'jmongo' : 'mongo'

require 'core_ext/hash'
require 'jmongo-i18n/mongo_store'
