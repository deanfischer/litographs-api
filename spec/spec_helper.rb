RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
require 'airborne'

SEED_DATA_BASEPATH = File.join(File.dirname(__FILE__), '/../db/seeds/')

RSpec.configure do |conf|
  # conf.mock_with :mocha
  # conf.include Rack::Test::Methods
end

Airborne.configure do |config|
  config.rack_app = Padrino.application
end





# You can use this method to custom specify a Rack app
# you want rack-test to invoke:
#
#   app Litographs::API
#   app Litographs::API.tap { |a| }
#   app(Litographs::API) do
#     set :foo, :bar
#   end
#
def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end


# #
# Helpers
# #

def user_obj 
  {
    first_name: "Dean",
    last_name: "Fischer",
    email: "dean@fischer.com",
    gender: "male",
    dob: "23rd June 1989",
    genres: Hash[ Genre.all.map{|genre| [genre.slug.to_sym, !!['classics','biography'].include?(genre.slug)]} ],
  }
end

def full_server_side_user_obj
  obj = user_obj
  obj.delete(:dob) # date comparisons are hard
  obj
end

def address_obj
  {
    line1: "Flat 4",
    street: "Druid St",
    city: "Cambridge",
    state: "New York",
    zip: "98109"
  }
end

def full_server_side_address_obj
  address_obj.merge({line2: nil, country:"USA"})
end

