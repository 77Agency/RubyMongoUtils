# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongo_utils/version'

Gem::Specification.new do |gem|
  gem.name          = 'ruby_mongo_utils'
  gem.version       = MongoUtils::VERSION
  gem.authors       = ['Nikita Cernovs']
  gem.email         = ['n.cernovs@77agency.com']
  gem.description   = %q{Ruby Mongo Utilities}
  gem.summary       = %q{Ruby Mongo Utilities}
  gem.homepage      = 'http://77agency.github.io/RubyMongoUtils'

  gem.add_dependency 'mongoid'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'database_cleaner'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
end
