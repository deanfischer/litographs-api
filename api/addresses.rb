require_relative 'api'
require_relative "helpers/users_helpers"
require_relative "helpers/addresses_helpers"


module Litographs
  class Api
    resource :users do
      segment '/:user_id' do
        resource :addresses do

          before do
            @user = require_user
          end

          # #
          # POST
          # #

          desc "Create an address", {
            params: Address::Entity.documentation
          }
          params do
            optional :name, type: String
            optional :line1, type: String
            optional :line2, type: String
            optional :street, String
            at_least_one_of :line1, :line2, :street
            optional :city, String
            optional :state, String
            optional :province, String
            optional :country, String, default: "USA"
            optional :zip, String
            optional :phone, String
          end
          post do
            if new_address = @user.addresses.create(extract_address_params(params))
              present new_address
            else
              error!({message:'Could not create address', errors: new_address.errors.to_h}, 403)
            end
          end

        end
      end
    end
  end
end 