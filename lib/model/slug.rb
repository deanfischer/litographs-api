# #
# Slug extension for datamapper. Generates unique slugs based on a name string. Accepts scopes.
# #

module Litographs
  module Slug

    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end


    module ClassMethods

      attr_reader :slug_options

      def has_slug(options={})
        options = {:gen_from => :name, :index => false, :scope => []}.merge options
        options[:scope] = Array(options[:scope])
        @slug_options = options

        property :slug, ::DataMapper::Property::String, index: options[:index]

        before :create do
          update_slug
        end

      end

    end


    module InstanceMethods

      def slug_scope
        Hash[ model.slug_options[:scope].map { |p| [ p, attribute_get(p) ] } ]
      end
      # Finds a unique slug (for the given scope) for this instance by appending an incremental
      # count to the slugified version of the instances name.
      def update_slug
        source = self[model.slug_options[:gen_from]] || ""
        slug = ActiveSupport::Inflector.transliterate(source) # remove accents
          .gsub(/&/,'and')          # switch out &
          .gsub(/@/,'at')           # switch out @
          .parameterize('-')        # cleanup remaining odd characters and link with hyphens
        if slug.length > 0
          if s = unique_slug(slug)
            slug = s
          end
        else
          slug = random_slug
        end
        self.slug = slug
      end

      def unique_slug(slug)
        count = 1
        conditions = slug_scope.merge({slug: slug})
        model_with_slug = model.first(conditions)
        while model_with_slug
          return if model_with_slug == self
          old_count = "-" + count.to_s
          slug = slug.sub(/#{old_count}$/,"") + "-" + (count + 1).to_s
          conditions = slug_scope.merge({slug: slug})
          model_with_slug = model.first(conditions)
          count += 1
        end
        slug
      end

      def random_slug
        require 'securerandom'
        SecureRandom.random_number(36**12).to_s(36).rjust(12, "0")
      end
    end

  end # Slug
end # Litographs