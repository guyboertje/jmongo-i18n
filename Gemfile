source "http://rubygems.org"
gemspec

platforms :ruby do
  @dependencies.delete_if {|d| d.name == 'jmongo' }
  gem 'mongo'
end

platforms :jruby do
  @dependencies.delete_if {|d| d.name == 'mongo' }
  gem 'jmongo', :git => 'https://github.com/guyboertje/jmongo.git'
end
