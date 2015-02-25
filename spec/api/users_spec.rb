require_relative "../spec_helper.rb"
require 'airborne'

describe "Users API" do

  before :all do
    User.all.destroy
    Genre.all.destroy
    seed_genres = YAML.load_file(File.join(SEED_DATA_BASEPATH, "genres.yml"))
    seed_genres.each{ |genre| Genre.create(genre) }
  end

  after :each do 
    User.all.destroy
  end

  describe "POST /users" do
    it "accepts a user object and returns a fully created user" do
      post "/v1/users", user_obj
      expect_json full_server_side_user_obj
    end
  end

  describe "GET /users/:id" do
    it "returns a user by id" do
      user = User.create(user_obj)
      expect(user.saved?).to eql(true)
      get "/v1/users/#{user.id}"

      expect_json_types({
        id: :integer,
        first_name: :string_or_null,
        last_name: :string_or_null
      })
      expect_json_types( "addresses.0", optional({
        name: :string_or_null,
        line1: :string_or_null,
        line2: :string_or_null,
        street: :string_or_null,
        city: :string,
        state: :string,
        province: :string_or_null,
        zip: :string,
        phone: :string_or_null,
        genres: :array_of_strings_or_null
      }))
      expect_json({
        gender: lambda { |gender| gender == nil || regex("male|female|other|unspecified").match(gender)},
        dob: lambda { |dob| dob == nil || DateTime.parse(dob) - user.dob.to_datetime < 1000 * 60 },
        email: regex(".+@.+")
      })

      user.destroy
      get "/v1/users/#{user.id}"
      expect_status 404
    end
  end

  describe "PATCH /users/:id" do
    it "accepts a partial user object and returns an updated user" do
      user_id = User.create(user_obj).id
      updated_user_obj = {first_name: "Rodrigo", last_name: "Hernandez", gender: 'unspecified'}
      patch "/v1/users/#{user_id}", updated_user_obj
      expect_json full_server_side_user_obj.merge(updated_user_obj)
      patch "/v1/users/#{user_id}", user_obj
      expect_json full_server_side_user_obj
    end
  end

  # describe "Update and entire user" do
  #   it "returns an updated user object" do
  #     user_id = User.create(user_obj).id
  #     updated_user_obj = user_obj.deep_dup.merge!(first_name: "Rodrigo", last_name: "Hernandez", gender: 'unspecified')
  #     put "/v1/users/#{user_id}", updated_user_obj
  #     expect_json full_server_side_user_obj.deep_dup.merge!(first_name: "Rodrigo", last_name: "Hernandez", gender: 'unspecified')
  #     put "/v1/users/#{user_id}", user_obj
  #     expect_json full_server_side_user_obj
  #   end
  # end

end


