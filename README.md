# MongoUtils

Ruby Mongo Utilities

## Installation

Add this line to your application's Gemfile:

    gem 'ruby_mongo_utils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_mongo_utils

## Usage

### Stripable

Include MongoUtils::Stripable in your classes in order to prevent stroring nil, [], {}, 0, false in the Mongo!

    class Page
      include MongoUtils::Stripable
     end

## MongoDump and MongoRestore

Provide MongoDump with collection name, query and a path in order to backup entries:

    MongoUtils::MongoDump.call(
      collection: Page.collection_name,
      query:      "{ 'page_type': { '\\$ne': 'Wordpress' } }",
      path:       "#{Rails.root}/mongodumps"
    )

Provide MongoRestore with collection name, filter and a path in order to restore matching entries:

    MongoUtils::MongoRestore.call(
      collection: Page.collection_name,
      filter:     "{ 'page_type': 'Facebook' }",
      path:       "#{Rails.root}/mongodumps"
    )

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
