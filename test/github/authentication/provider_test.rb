# frozen_string_literal: true
require "test_helper"

require "github/authentication/provider"

module Github
  module Authentication
    class ProviderTest < Minitest::Test
      def test_reset_token_resets
        generator = mock
        token = mock
        token.stubs(:valid_for?).returns(true)
        cache = mock
        cache.stubs(:read).returns(token).twice
        cache.stubs(:clear).once
        provider = Provider.new(generator: generator, cache: cache)

        provider.token
        provider.reset_token
        provider.token
      end

      def test_token_valid_return_token
        generator = mock
        token = mock
        token.stubs(:valid_for?).returns(true)
        cache = mock
        cache.stubs(:read).returns(token).once
        provider = Provider.new(generator: generator, cache: cache)

        result_token_not_cached = provider.token
        result_token_cached = provider.token

        assert result_token_not_cached == result_token_cached
      end

      def test_token_not_present_generates_token
        token = mock
        token.stubs(:valid_for?).returns(true)
        generator = mock
        generator.stubs(:generate).returns(token)
        cache = mock
        cache.stubs(:read).returns(nil)
        cache.stubs(:write).with(token)
        provider = Provider.new(generator: generator, cache: cache)

        result = provider.token

        assert_equal token, result
      end

      def test_token_not_present_generates_invalid_token_tries_again
        valid_token = mock
        valid_token.stubs(:valid_for?).returns(true)
        invalid_token = mock
        invalid_token.stubs(:valid_for?).returns(false)
        generator = mock
        generator.stubs(:generate).returns(invalid_token).then.returns(valid_token)
        cache = mock
        cache.stubs(:read).returns(nil)
        cache.stubs(:write).once
        provider = Provider.new(generator: generator, cache: cache)

        result = provider.token
        assert result.valid_for?
      end

      def test_inspect
        provider = Provider.new(generator: false, cache: false)

        result = provider.inspect

        assert_equal '#<Github::Authentication::Provider>', result
      end
    end
  end
end
