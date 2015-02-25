require 'grape'

class Address
  include DataMapper::Resource

  property :id, Serial
  property :name, String, length: 1..40
  property :line1, String, length: 1..100
  property :line2, String, length: 1..100
  property :street, String, length: 1..100
  property :state, String, length: 1..40
  property :city, String, length: 1..40
  property :country, String, length: 1..40, :default => "USA"
  property :province, String, length: 1..40
  property :zip, String, length: 1..40
  property :phone, String, length: 1..40

  belongs_to :user

  class Entity < Grape::Entity
    expose :id, documentation: { type: "Integer", desc: "The unique ID for this address" }
    expose :name, documentation: { type: "String", desc: "Name of occupant." } do |address, options|
      address.name || address.user.full_name
    end
    expose :line1, documentation: { type: "String", desc: "Address line 1." }
    expose :line2, documentation: { type: "String", desc: "Address line 2." }
    expose :street, documentation: { type: "String", desc: "Street name." }
    expose :state, documentation: { type: "String", desc: "State name." }
    expose :city, documentation: { type: "String", desc: "City name." }
    expose :country, documentation: { type: "String", desc: "Country." }
    expose :zip, documentation: { type: "String", desc: "Zip code." }
  end

  def entity
    Address.new(self)
  end

end