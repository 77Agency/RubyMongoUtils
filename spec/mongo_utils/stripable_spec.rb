require 'spec_helper'

describe MongoUtils::Stripable do
  context 'on create' do
    it 'should not store blank default values' do
      page = Page.create!

      page.name.should eq nil
      page.tags.should eq []
      page.likes.should eq({ lifetime: { total: 0 } })
      page.posts.should eq []

      Page.collection.find.first.keys.should eq ['_id']
    end

    it 'should not store blank or zero values' do
      page = Page.create! name: '', tags: [], likes: nil

      page.name.should eq nil
      page.tags.should eq []
      page.likes.should eq({ lifetime: { total: 0 } })
      page.posts.should eq []

      Page.collection.find.first.keys.should eq ['_id']
    end

    it 'should store values with content' do
      page = Page.create! name: 'Name', tags: ['a']      

      page.name.should eq 'Name'
      page.tags.should eq ['a']
      page.likes.should eq({ lifetime: { total: 0 } })
      page.posts.should eq []

      page = Page.collection.find.first
      page.keys.sort.should eq ['_id', 'name', 'tags']
      page['name'].should eq 'Name'
      page['tags'].should eq ['a']
    end

    it 'should recursiverly detect if hash has no values' do
      page = Page.create! likes: { lifetime: { user555: 0 } }

      page.name.should eq nil
      page.tags.should eq []
      page.likes.should eq({ lifetime: { total: 0 } })
      page.posts.should eq []

      Page.collection.find.first.keys.sort.should eq ['_id']
    end

    it 'should recursiverly detect if hash has values' do
      page = Page.create! likes: { lifetime: { user555: 42 } }

      page.name.should eq nil
      page.tags.should eq []
      page.likes.should eq({ lifetime: { user555: 42 } })
      page.posts.should eq []

      page = Page.collection.find.first
      page.keys.sort.should eq ['_id', 'likes']
      page['likes'].should eq({ 'lifetime' => { 'user555' => 42 } })
    end

    it 'should recursiverly strtip blank values from hash and save the rest' do
      page = Page.create! likes: { lifetime: { user555: 42, user777: 0 } }

      page.likes.should eq({ lifetime: { user555: 42 } })

      Page.collection.find.first['likes'].should eq({ 'lifetime' => { 'user555' => 42 } })
    end

    it 'should not strip empty values from embedded document when save is called on it' do
      page = Page.new
      post = page.posts.build
      page.save!

      post.message.should eq ''
      post.likes.should eq 0

      posts = Page.collection.find.first['posts']
      posts.count.should eq 1

      post = posts.first
      post.keys.sort.should eq ['_id', 'likes', 'message']
      post['message'].should eq ''
      post['likes'].should eq 0
    end

    it 'should strip empty values from embedded document when save is called on it' do
      page = Page.create!
      post = page.posts.build
      post.save!

      post.message.should eq ''
      post.likes.should eq 0

      posts = Page.collection.find.first['posts']
      posts.count.should eq 1
      posts.first.keys.should eq ['_id']
    end

    it 'should save embedded document fields' do
      page = Page.create!
      post = page.posts.build message: 'Message of the post!', likes: 2
      post.save!

      post.message.should eq 'Message of the post!'
      post.likes.should eq 2

      posts = Page.collection.find.first['posts']
      posts.count.should eq 1

      post = posts.first
      post.keys.sort.should eq ['_id', 'likes', 'message']
      post['message'].should eq 'Message of the post!'
      post['likes'].should eq 2
    end
  end

  describe 'stored post' do
    before do
      @page = Page.new({
        name: 'Page name',
        tags: ['A', 'B', 'C']
      })
      @page.posts.build({ message: 'Post1'})
      @page.save!
    end

    it 'should be fetched properly' do
      page = Page.first
      page.name.should eq 'Page name'
      page.tags.should eq ['A', 'B', 'C']
      page.likes.should eq({ lifetime: { total: 0 } })
      page.posts.count.should eq 1

      post = page.posts.first
      post.message.should eq 'Post1'
      post.likes.should eq 0
    end

    it 'should look in DB correctly' do
      page = Page.collection.find.first

      page.keys.sort.should eq ['_id', 'name', 'posts', 'tags']
      page['name'].should eq 'Page name'
      page['tags'].should eq ['A', 'B', 'C']
      page['posts'].count.should eq 1

      post = page['posts'].first

      post.keys.sort.should eq ['_id', 'likes', 'message']
      post['message'].should eq 'Post1'
      post['likes'].should eq 0
    end

    context 'on update' do
      it 'should set present value to blank' do
        page = Page.first
        page.name = ''
        page.save!      

        page.name.should eq ''

        page = Page.collection.find.first
        page.keys.should include 'name'
        page['name'].should eq ''
      end

      it 'should not set nil value to default empty value' do
        page = Page.first
        page.name = 'Page name 2'
        page.save!      

        page.likes.should eq({ lifetime: { total: 0 } })

        page = Page.collection.find.first
        page.keys.should_not include 'likes'
      end

      it 'should not set nil values after multiple updates' do
        page = Page.first
        page.admins = [1,2,3]
        page.save!

        page.reload

        page.admins.should eq([1,2,3])

        page.admins = []

        page.save!

        page.reload

        page.reload.admins.should eq([])

        page.name = 'Page name 3'

        page.save!

        page.reload.admins.should eq([])

        page = Page.collection.find.first
        page.keys.should include 'admins'
      end

      it 'should allow to set a value to a blank' do
        page = Page.first
        page.tags = []
        page.save!

        page.tags.should eq []

        page = Page.collection.find.first
        page['tags'].should eq([])
      end

      it 'should not set empty value to another empty value' do
        page = Page.first
        page.likes = { three_months: { total: 0 } }
        page.save!

        page.likes.should eq({ lifetime: { total: 0 } })

        page = Page.collection.find.first
        page.keys.should_not include 'likes'
      end

      it 'should not set empty value to another empty value in the second level hash' do
        page = Page.first
        page.likes[:lifetime] = { by_user: 0 }
        page.save!

        page.likes.should eq({ lifetime: { total: 0 } })

        page = Page.collection.find.first
        page.keys.should_not include 'likes'
      end

      it 'should update an empty value to another' do
        page = Page.first
        page.likes[:lifetime] = { user777: 77 }
        page.save!

        page.likes.should eq({ lifetime: { user777: 77 } })

        page = Page.collection.find.first
        page.keys.should include 'likes'
      end

      context 'after update' do
        before do
          page = Page.first
          page.likes[:lifetime] = { user777: 77, user555: 0, total: { by_user: [] } }
          page.save!
        end

        it 'should be able to add another key to the hash' do
          page = Page.first
          page.likes[:totals] = 55
          page.save!

          page = Page.first
          page.likes['totals'].should eq 55
          page.likes['lifetime'].should eq({ 'user777' => 77 , 'user555' => 0, 'total' => { 'by_user' => [] } })
        end

        it 'should be able to add another key to the second level hash' do
          page = Page.first
          page.likes['lifetime']['user555'] = 55
          page.save!

          page = Page.first
          page.likes['lifetime']['user555'].should eq 55
          page.likes['lifetime']['user777'].should eq 77
        end

        it 'should be able to make existing key inside a hash to an empty value' do
          page = Page.first
          page.likes['lifetime']['user777'] = 0
          page.save!

          page = Page.first
          page.likes['lifetime']['user777'].should eq 0
        end

        it 'should be able to make existing key inside a hash to empty value and set another value' do
          page = Page.first
          page.likes['lifetime']['user555'] = 55
          page.likes['lifetime']['user777'] = 0
          page.save!

          page = Page.first
          page.likes['lifetime'].should eq({ 'user777' => 0, 'user555' => 55, 'total' => { 'by_user' => [] } })
        end
      end
    end
  end
end
