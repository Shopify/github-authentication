# frozen_string_literal: true

require 'github/authentication/token'

module Github
  module Authentication
    class ObjectCache
      def initialize
        @cache = {}
      end

      def read(key)
        return unless @cache.key?(key)

        options = @cache[key][:options]
        if options.key?(:expires_at) && Time.now.utc > options[:expires_at]
          @cache.delete(key)
          return nil
        end

        @cache[key][:value]
      end

      def write(key, value, options = {})
        if options.key?(:expires_in)
          options[:expires_at] = Time.now.utc + options[:expires_in]
        end
        @cache[key] = { value: value, options: options }
      end

      def clear(key)
        @cache.delete(key)
      end
    end
  end
end
