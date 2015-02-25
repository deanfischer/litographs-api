class Genre
  include DataMapper::Resource
  include Litographs::Slug

  property :id, Serial
  property :name, String, length: 1..40

  has_slug gen_from: :name, index: true

  has n, :user_genres

end