# frozen_string_literal: true

require "test_helper"
require "securerandom"
require "active_support"
require "active_support/core_ext/numeric"

module GithubAuthentication
  class GitCredentialHelperTest < Minitest::Test
    include GithubAPIHelper

    def setup
      @pem = File.read("test/fixtures/dummy_private_key.pem")
      @app_id = rand(1000)
      @installation_id = rand(10000)
      @description = ""
    end

    def test_handle_get_prints_credential
      stub_description
      stub_create_installation_access_token(token: "s3cret")
      out, err = capture_io do
        assert_predicate helper.handle_get, :zero?
      end

      assert_empty(err)
      assert_equal "password=s3cret\nusername=api", out.strip
    end

    def test_handle_get_errors_on_unknown_host
      stub_description(host: "not.github.com")

      out, err = capture_io do
        assert_predicate helper.handle_get, :nonzero?
      end

      refute_empty(err)
      assert_empty(out)
    end

    private

    def helper
      @helper ||= GitCredentialHelper.new(
        pem: @pem,
        app_id: @app_id,
        installation_id: @installation_id,
        description: @description,
      )
    end

    def stub_description(protocol: "https", host: "github.com", path: nil)
      @description = {
        "protocol" => protocol,
        "host" => host,
      }

      @description["path"] = path unless path.nil?
      @description
    end
  end
end
