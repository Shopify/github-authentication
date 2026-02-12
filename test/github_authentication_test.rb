# frozen_string_literal: true

require "test_helper"

require "github_authentication"

class AuthenticationTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GithubAuthentication::VERSION
  end

  def test_provider_returns_a_provider
    env = {
      "GITHUB_APP_ID" => "123",
      "GITHUB_APP_INSTALLATION_ID" => "456",
    }

    create_test_keyfile do |path|
      env["GITHUB_APP_KEYFILE"] = path
      provider = GithubAuthentication.provider(org: "shopify", env: env)
      assert_instance_of(GithubAuthentication::Provider, provider)
    end
  end

  def test_provider_falls_back_to_object_cache_when_storage_path_not_set
    env = {
      "GITHUB_APP_ID" => "123",
      "GITHUB_APP_INSTALLATION_ID" => "456",
    }

    create_test_keyfile do |path|
      env["GITHUB_APP_KEYFILE"] = path
      provider = GithubAuthentication.provider(org: "shopify", env: env)

      cache = provider.instance_variable_get(:@cache)
      storage = cache.instance_variable_get(:@storage)
      assert_instance_of(GithubAuthentication::ObjectCache, storage)
    end
  end

  def test_provider_uses_file_store_when_storage_path_set
    env = {
      "GITHUB_APP_ID" => "123",
      "GITHUB_APP_INSTALLATION_ID" => "456",
      "GITHUB_APP_CREDENTIAL_STORAGE_PATH" => "/tmp/test_credential_storage",
    }

    create_test_keyfile do |path|
      env["GITHUB_APP_KEYFILE"] = path
      provider = GithubAuthentication.provider(org: "shopify", env: env)

      cache = provider.instance_variable_get(:@cache)
      storage = cache.instance_variable_get(:@storage)
      assert_instance_of(ActiveSupport::Cache::FileStore, storage)
    end
  end

  private

  def create_test_keyfile(content: OpenSSL::PKey::RSA.generate(2048).to_pem)
    Tempfile.create("test_keyfile.pem") do |f|
      File.write(f.path, content)
      yield f.path
    end
  end
end
