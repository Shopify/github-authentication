# frozen_string_literal: true

require 'github_authentication/token'

module GithubAuthentication
  class Cache
    # storage = ActiveSupport::Cache
    def initialize(storage:, key: '')
      @storage = storage
      @key = "github:authentication:#{key}"
    end

    def read
      json = @storage.read(@key)
      Token.from_json(json)
    end

    def write(token)
      @storage.write(@key, token.to_json, expires_in: token.expires_in)
    end

    def clear
      @storage.delete(@key)
    end
  end
end
