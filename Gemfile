source "http://rubygems.org"
gemspec

platforms :ruby do
  @dependencies.delete_if {|d| d.name == 'jmongo' }
  gem 'bson_ext'
  gem 'mongo'
end

platforms :jruby do
  @dependencies.delete_if {|d| d.name == 'mongo' }
  @dependencies.delete_if {|d| d.name == 'bson_ext' }
  gem 'jmongo', :git => 'https://github.com/guyboertje/jmongo.git'
end
