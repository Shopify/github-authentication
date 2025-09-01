# frozen_string_literal: true

require "test_helper"
require "github_authentication/environment"

module GithubAuthentication
  class EnvironmentTest < Minitest::Test
    def setup
      @original_env = ENV.to_h
      @org = "shopify"
      @env = Environment.new(org: @org)

      # Clear any existing environment variables
      ENV.delete("GITHUB_APP_KEYFILE")
      ENV.delete("GITHUB_APP_ID")
      ENV.delete("GITHUB_APP_INSTALLATION_ID")
      ENV.delete("GITHUB_APP_CREDENTIAL_STORAGE_PATH")
      ENV.delete("SHOPIFY_GITHUB_APP_KEYFILE")
      ENV.delete("SHOPIFY_GITHUB_APP_ID")
      ENV.delete("SHOPIFY_GITHUB_APP_INSTALLATION_ID")
      ENV.delete("SHOPIFY_GITHUB_APP_CREDENTIAL_STORAGE_PATH")
    end

    def teardown
      ENV.replace(@original_env)
    end

    def test_org_instance_variable_is_used_for_env_var_resolution
      env = Environment.new(org: "custom_org")
      ENV["CUSTOM_ORG_GITHUB_APP_ID"] = "custom_org_id"

      result = env.app_id
      assert_equal "custom_org_id", result
    end

    def test_pem_uses_org_specific_env_var_when_available
      create_test_keyfile("test_keyfile.pem") do |path|
        ENV["SHOPIFY_GITHUB_APP_KEYFILE"] = path
        result = @env.pem
        assert_equal "test_key_content", result
      end
    end

    def test_pem_falls_back_to_generic_env_var_when_org_specific_not_available
      create_test_keyfile("test_keyfile.pem") do |path|
        ENV["GITHUB_APP_KEYFILE"] = path
        result = @env.pem
        assert_equal "test_key_content", result
      end
    end

    def test_pem_raises_error_when_neither_env_var_is_set
      assert_raises(KeyError) do
        @env.pem
      end
    end

    def test_pem_raises_error_when_file_does_not_exist
      ENV["SHOPIFY_GITHUB_APP_KEYFILE"] = "nonexistent_file.pem"

      assert_raises(Errno::ENOENT) do
        @env.pem
      end
    end

    def test_app_id_uses_org_specific_env_var_when_available
      ENV["SHOPIFY_GITHUB_APP_ID"] = "12345"

      result = @env.app_id
      assert_equal "12345", result
    end

    def test_app_id_falls_back_to_generic_env_var_when_org_specific_not_available
      ENV["GITHUB_APP_ID"] = "67890"

      result = @env.app_id
      assert_equal "67890", result
    end

    def test_app_id_raises_error_when_neither_env_var_is_set
      assert_raises(KeyError) do
        @env.app_id
      end
    end

    def test_installation_id_uses_org_specific_env_var_when_available
      ENV["SHOPIFY_GITHUB_APP_INSTALLATION_ID"] = "11111"

      result = @env.installation_id
      assert_equal "11111", result
    end

    def test_installation_id_falls_back_to_generic_env_var_when_org_specific_not_available
      ENV["GITHUB_APP_INSTALLATION_ID"] = "22222"

      result = @env.installation_id
      assert_equal "22222", result
    end

    def test_installation_id_raises_error_when_neither_env_var_is_set
      assert_raises(KeyError) do
        @env.installation_id
      end
    end

    def test_storage_uses_org_specific_env_var_when_available
      ENV["SHOPIFY_GITHUB_APP_CREDENTIAL_STORAGE_PATH"] = "/custom/storage/path"

      result = @env.storage
      assert_equal "/custom/storage/path", result
    end

    def test_storage_falls_back_to_generic_env_var_when_org_specific_not_available
      ENV["GITHUB_APP_CREDENTIAL_STORAGE_PATH"] = "/default/storage/path"

      result = @env.storage
      assert_equal "/default/storage/path", result
    end

    def test_storage_raises_error_when_neither_env_var_is_set
      assert_raises(KeyError) do
        @env.storage
      end
    end

    def test_org_specific_env_vars_take_precedence_over_generic_ones
      ENV["SHOPIFY_GITHUB_APP_ID"] = "org_specific_id"
      ENV["GITHUB_APP_ID"] = "generic_id"

      result = @env.app_id
      assert_equal "org_specific_id", result
    end

    def test_case_sensitivity_of_org_name
      # Test that the org name is converted to uppercase when constructing env var names
      env = Environment.new(org: "MyOrg")
      ENV["MYORG_GITHUB_APP_ID"] = "myorg_id"

      result = env.app_id
      assert_equal "myorg_id", result
    end

    def test_empty_string_org_name_uses_default_env_var
      env = Environment.new(org: "")
      ENV["GITHUB_APP_ID"] = "empty_org_id"

      result = env.app_id
      assert_equal "empty_org_id", result
    end

    private

    def create_test_keyfile(name, content: "test_key_content")
      Tempfile.create(name) do |f|
        File.write(f.path, content)
        yield f.path
      end
    end
  end
end
