# frozen_string_literal: true
require 'test_helper'

module GithubAuthentication
  module Generator
    class AppTest < Minitest::Test
      include GithubAPIHelper

      def setup
        @pem = File.read('test/fixtures/dummy_private_key.pem')
        @app_id = rand(1000)
        @installation_id = rand(10000)
      end

      def test_generate
        generator = App.new(
          pem: @pem,
          app_id: @app_id,
          installation_id: @installation_id,
        )

        Timecop.freeze do
          stub_create_installation_access_token(token: 's3cret')
          token = generator.generate

          assert_equal 1.hour.from_now.iso8601, token.expires_at.iso8601
          assert_equal 's3cret', token.to_s
        end
      end

      def test_generate_handles_errors
        generator = App.new(
          pem: @pem,
          app_id: @app_id,
          installation_id: @installation_id,
        )

        stub_create_installation_access_token_error
        assert_raises(TokenGeneratorError) { generator.generate }
      end
    end
  end
end
