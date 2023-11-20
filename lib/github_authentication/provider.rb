# frozen_string_literal: true

require "github_authentication/retriable"

module GithubAuthentication
  class Provider
    include Retriable

    Error = Class.new(StandardError)
    TokenGeneratorError = Class.new(Error)

    def initialize(generator:, cache:)
      @token = nil
      @generator = generator
      @cache = cache
      @mutex = Mutex.new
    end

    def token(seconds_ttl: 5 * 60)
      return @token if @token&.valid_for?(seconds_ttl)

      with_retries(TokenGeneratorError) do
        @mutex.synchronize do
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
