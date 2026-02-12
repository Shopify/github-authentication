# frozen_string_literal: true

require "github_authentication/version"
require "github_authentication/environment"
require "github_authentication/generator"
require "github_authentication/provider"
require "github_authentication/cache"
require "github_authentication/object_cache"
require "github_authentication/git_credential_helper"

module GithubAuthentication
  class << self
    def provider(org:, env: ENV)
      ga_env = Environment.new(org: org, env: env)
      generator = Generator::App.new(
        pem: ga_env.pem,
        installation_id: ga_env.installation_id,
        app_id: ga_env.app_id,
      )
      storage = begin
        ga_env.storage
      rescue KeyError
        ObjectCache.new
      end
      cache = Cache.new(storage: storage, key: org)
      Provider.new(generator: generator, cache: cache)
    end
  end
end
