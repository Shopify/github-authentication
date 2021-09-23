# frozen_string_literal: true
require 'test_helper'
require 'securerandom'
require "active_support"
require "active_support/core_ext/numeric"

module GithubAuthentication
  class GitCredentialHelperTest < Minitest::Test
    def setup
      @pem = File.read('test/fixtures/dummy_private_key.pem')
      @app_id = rand(1000)
      @installation_id = rand(10000)
      @stdin = StringIO.new

      @helper = GitCredentialHelper.new(
        pem: @pem,
        app_id: @app_id,
        installation_id: @installation_id,
        stdin: @stdin
      )
    end

    def test_handle_get_prints_credential
      stub_stdin
      stub_create_installation_access_token(token: "s3cret")
      out, err = capture_io do
        assert_predicate @helper.handle_get, :zero?
      end

      assert_empty(err)
      assert_equal "password=s3cret\nusername=api", out.strip
    end

    def test_handle_get_errors_on_unknown_host
      stub_stdin(host: 'not.github.com')

      out, err = capture_io do
        assert_predicate @helper.handle_get, :nonzero?
      end

      refute_empty(err)
      assert_empty(out)
    end

    private

    def stub_create_installation_access_token(token: SecureRandom.hex)
      stub_request(:post, "https://api.github.com/app/installations/#{@installation_id}/access_tokens")
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: { token: token, expires_at: 1.hour.from_now.iso8601 }.to_json,
          status: 201,
        )
    end

    def stub_stdin(protocol: 'https', host: 'github.com', path: nil)
      @stdin.write("protocol=#{protocol}\nhost=#{host}\n")
      @stdin.write("path=#{path}\n") unless path.nil?

      @stdin.rewind
    end
  end
end
