require 'spec_helper'

describe MongoUtils::MongoRestore do
  it 'should create backup files and be able to restore from it' do
    10.times { Page.create! page_type: 'Facebook'  }
    10.times { Page.create! page_type: 'Google+'   }
    10.times { Page.create! page_type: 'Wordpress' }

    Page.count.should eq 30

    path = "#{Dir.pwd}/mongodumps"

    MongoUtils::MongoDump.call(
      collection: Page.collection_name,
      query:      "{ 'page_type': { '\\$ne': 'Wordpress' } }",
      path:       path
    )

    Page.count.should eq 30

    Page.destroy_all

    Page.count.should eq 0

    MongoUtils::MongoRestore.call(
      collection: Page.collection_name,
      filter:     "{ 'page_type': 'Facebook' }",
      path:       path
    )

    Page.count.should eq 10

    MongoUtils::MongoRestore.call(
      collection: Page.collection_name,
      filter:     "{ 'page_type': 'Google+' }",
      path:       path
    )

    Page.count.should eq 20

    FileUtils.rm_rf(path)   
  end
end
