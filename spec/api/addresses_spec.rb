require_relative "../spec_helper.rb"
require 'airborne'

describe "Addresses API" do

  before :all do
    User.all.destroy
    Genre.all.destroy
    seed_genres = YAML.load_file(File.join(SEED_DATA_BASEPATH, "genres.yml"))
    seed_genres.each{ |genre| Genre.create(genre) }
    User.create(user_obj)
  end

  after :all do 
    User.all.destroy
    Genre.all.destroy
  end

  # #
  # Helpers
  # #

  describe "POST /users/:user_id/addresses" do
    it "accepts an address object and creates an address" do
      user = User.last
      post "/v1/users/#{user.id}/addresses", address_obj
      expect_json full_server_side_address_obj
      get "/v1/users/#{user.id}"
      expect_json "addresses.0", full_server_side_address_obj
    end
  end


end


