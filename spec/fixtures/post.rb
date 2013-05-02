class Post
  include Mongoid::Document
  include MongoUtils::Stripable

  field :message, type: String, default: ''
  field :likes,   type: Integer, default: 0

  embedded_in :page
end
