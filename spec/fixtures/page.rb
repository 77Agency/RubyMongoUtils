class Page
  include Mongoid::Document
  include MongoUtils::Stripable

  field :name,   type: String
  field :tags,   type: Array, default: []
  field :likes,  type: Hash,  default: { lifetime: { total: 0 } }
  field :admins, type: Array, default: []

  embeds_many :posts
end
