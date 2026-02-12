# frozen_string_literal: true

module GithubAuthentication
  class GitCredentialHelper
    def initialize(provider:, description:)
      @provider = provider
      @description = description
    end

    def handle_get
      unless @description["protocol"] == "https" && @description["host"] == "github.com"
        warn("Unsupported description: #{@description}")
        return 2
      end

      token = @provider.token(seconds_ttl: min_cache_ttl)
      puts("password=#{token}")
      puts("username=api")

      0
    end

    private

    def min_cache_ttl
      # Tokens are valid for 60 minutes, allow a 10 minute buffer
      10 * 60
    end
  end
end
