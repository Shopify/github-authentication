# frozen_string_literal: true

require 'github/authentication/token'

module Github
  module Authentication
    class ObjectCache
      def initialize
        @cache = {}
      end

      def read(key)
        return unless @cache.has_key?(key)

        options = @cache[key][:options]
        if options.has_key?(:expires_at) && Time.now > options[:expires_at]
          @cache.delete(key)
          return nil
        end

        @cache[key][:value]
      end

      def write(key, value, options = {})
        if options.has_key?(:expires_in)
          options[:expires_at] = Time.now + options[:expires_in] * 60
        end
        @cache[key] = { value: value, options: options }
      end

      def clear(key)
        @cache.delete(key)
      end
    end
  end
end

