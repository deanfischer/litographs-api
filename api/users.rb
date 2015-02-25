require_relative "helpers/users_helpers"
require_relative 'api'

module Litographs
  class Api
    resource :users do

      # #
      # POST
      # #

      desc "Create a user", {
        params: User::Entity.documentation
      }
      params do
        use :optional_user_params
        requires :email, regexp: /.+@.+/
      end
      post do
        if new_user = User.create(extract_user_params(params))
          present new_user
        else
          error!({message:'Could not create user', errors: user.errors.to_h}, 403)
        end
      end



      # # # #
      # WITH :ID
      # # # #


      params do
        requires :id, type: Integer, desc: "User id."
      end
      route_param :id do


        # #
        # GET
        # #

        desc "Get a user by id"
        get do
          if user = User.get(params[:id])
            present user
          else
            error! 'No such user', 404
          end
        end


        # #
        # PATCH
        # #

        desc "Update a partial user",{
          params: User::Entity.documentation
        }
        params do
          use :optional_user_params
          optional :email, regexp: /.+@.+/
        end
        patch do
          if (user = User.get(params[:id])).update( extract_user_params(params) )
            present user
          else
            error!({message:'Could not update user', errors: user.errors.to_h}, 403)
          end
        end


        # # #
        # # PUT
        # # #

        # desc "Update an entire user", {
        #   params: User::Entity.documentation
        # }
        # params do
        #   use :optional_user_params
        # end
        # put do
        #   if user = User.get(params[:id]).update( extract_user_params(params) )
        #     present user
        #   else
        #     error!({message:'Could not update user', errors: user.errors.to_h}, 403)
        #   end
        # end


        # #
        # DELETE
        # #

        desc "Delete a user"
        delete do
          User.get(params[:id]).destroy
          {status: 200}
        end

      end

    end

  end
end 