require_relative 'grape_validators'

module Litographs
  class Api

    helpers do

      def require_user
        user = User.get(params[:user_id])
        error! "No such user: #{params[:user_id]}.", 404 if user.nil?
        user
      end

      def extract_user_params(params)
        whitelist = ["first_name", "last_name", "gender", "dob", "password", "email", "address", "genres"]
        extracted = params.select {|k,v| whitelist.include?(k.to_s) }
      end

      params :optional_user_params do
        optional :first_name, type: String, length: 40
        optional :last_name, type: String, length: 40
        optional :gender, type: String, default: 'unspecified', values: ['male', 'female', 'other', 'unspecified']
        optional :dob, type: String
        optional :password, type: String, length: 40

        optional :genres, type: Hash do
          optional :classics, type: Boolean
          optional :literary_fiction, type: Boolean
          optional :mysteries, type: Boolean
          optional :romance, type: Boolean
          optional :food, type: Boolean
          optional :ya, type: Boolean
          optional :biography, type: Boolean
        end
      end

    end
  end
end