# #
# API Base class
# This sets up the api and contains any settings or helpers
# that apply beyond a single resource
# #

module Litographs
  class Api < Grape::API

    # #
    # Settings
    # #
    
    format :json
    default_format :json
    version 'v1', using: :path



    # #
    # Helpers
    # #

    helpers do
      def current_user
        @current_user ||= User.authorize!(env)
      end

      def authenticate!
        error!('401 Unauthorized', 401) unless current_user
      end
    end

  end
end