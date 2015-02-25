module Litographs
  class Api

    helpers do

      def require_address
        address = Address.get(params[:address_id])
        error! "No such address: #{params[:address_id]}.", 404 if address.nil?
        address
      end

      def extract_address_params(params)
        whitelist = Address.properties.map{|p| p.name.to_s unless p.name == :id}.compact
        extracted = params.select {|k,v| whitelist.include?(k.to_s) }
      end
      
    end
  end
end