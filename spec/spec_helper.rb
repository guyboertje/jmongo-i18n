$:.unshift(File.expand_path('../../lib', __FILE__))

require 'i18n'
require 'jmongo-i18n'
require 'rspec'

connection = Mongo::Connection.new
DB = connection.db('mongo-i18n-store-test')