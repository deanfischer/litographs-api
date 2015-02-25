# #
# User submitted date extension for datamapper
# #

module Litographs
  module UserDate

    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end


    module ClassMethods

      attr_reader :user_date_options

      def has_user_date(prop, options={})
        options = {:context => :past}.merge options
        @user_date_options = options
        property prop, ::DataMapper::Property::DateTime


        define_method "#{prop}=" do |date_string|
          if date = convert_user_date(date_string)
            self[prop] = date
          end
        end

      end

    end


    module InstanceMethods

      def convert_user_date(date_string)
        timestamp = Chronic.parse(date_string, model.user_date_options).to_datetime
      end
      
    end

  end # UserDate
end # Litographs