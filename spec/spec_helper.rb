require 'ruby_mongo_utils'

Mongoid::Config.send :load_configuration, { sessions: { default: { hosts: ['localhost:27017'] , database: 'mongo_utils_tests' } } }

require './spec/fixtures/page'
require './spec/fixtures/post'

require 'database_cleaner'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner.orm      = :mongoid
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
