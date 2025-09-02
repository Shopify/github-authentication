# frozen_string_literal: true

require "active_support/core_ext/object/blank.rb"

module GithubAuthentication
  class Environment
    def initialize(org:, env: ENV)
      @org = org.presence
      @env = env
    end

    def pem
      File.read(resolve("GITHUB_APP_KEYFILE"))
    end

    def app_id
      resolve("GITHUB_APP_ID")
    end

    def installation_id
      resolve("GITHUB_APP_INSTALLATION_ID")
    end

    def storage
      ActiveSupport::Cache::FileStore.new(resolve("GITHUB_APP_CREDENTIAL_STORAGE_PATH"))
    end

    private

    def resolve(suffix)
      if @org
        @env["#{@org.upcase}_#{suffix}"] || @env.fetch(suffix)
      else
        @env.fetch(suffix)
      end
    end
  end
end
