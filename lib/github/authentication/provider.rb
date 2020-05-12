# frozen_string_literal: true
require "mutex_m.rb"

require 'github/authentication/retriable'

module Github
  module Authentication
    class Provider
      include Retriable
      include Mutex_m

      Error = Class.new(StandardError)
      TokenGeneratorError = Class.new(Error)

      def initialize(generator:, cache:)
        super()
        @token = nil
        @generator = generator
        @cache = cache
      end

      def token(seconds_ttl: 5 * 60)
        return @token if @token&.valid_for?(seconds_ttl)

        with_retries(TokenGeneratorError) do
          mu_synchronize do
            return @token if @token&.valid_for?(seconds_ttl)

            if (@token = @cache.read)
              return @token if @token.valid_for?(seconds_ttl)
            end

            if (@token = @generator.generate)
              if @token.valid_for?(seconds_ttl)
                @cache.write(@token)
                return @token
              end
            end

            raise TokenGeneratorError, "Couldn't create a token with a TTL of #{seconds_ttl}"
          end
        end
      end

      def reset_token
        @token = nil
        @cache.clear
      end

      # prevent credential leak
      def inspect
        "#<#{self.class.name}>"
      end
    end
  end
end
