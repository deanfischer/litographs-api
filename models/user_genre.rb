class UserGenre
  include DataMapper::Resource

  property :id, Serial
  property :created_at, DateTime, default: ->(r, p){ DateTime.now }

  belongs_to :user
  belongs_to :genre

end