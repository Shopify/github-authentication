# frozen_string_literal: true
require 'test_helper'

require 'github/authentication/token'

module Github
  module Authentication
    class TokenTest < Minitest::Test
      def setup
        Timecop.freeze(Time.local(1990))
      end

      def teardown
        Timecop.return
      end

      def test_from_json_returns_nil_if_unparsable
        result = Token.from_json('tonhasntaoheu')

        assert_nil result
      end

      def test_from_json_returns_token_object
        result = Token.from_json('{"token":"foo","expires_at":"1990-01-01T00:00:00-05:00"}')

        assert_equal 'foo', result.to_s
        assert_equal Time.now, result.expires_at
      end

      def test_expires_in_returns_correct_number
        token = Token.new('foo', Time.now + 20*60)

        assert_equal 20, token.expires_in
      end

      def test_expired_returns_true_when_expired
        token = Token.new('foo', Time.now + 3*60)

        assert token.expired?
      end

      def test_expired_returns_false_when_not_expired
        token = Token.new('foo', Time.now + 10*60)

        refute token.expired?
      end

      def test_valid_for_returns_false_when_invalid
        token = Token.new('foo', Time.now + 10*60)

        assert token.valid_for?(9*60)
      end

      def test_valid_for_returns_true_when_valid
        token = Token.new('foo', Time.now + 10*60)

        refute token.valid_for?(11*60)
      end

      def test_inspect
        token = Token.new('foooooooooooof', Time.now)

        assert_equal '#<Github::Authentication::Token @token=fooooooooo... @expires_at=1990-01-01 00:00:00 -0500>', token.inspect
      end

      def test_to_json
        token = Token.new('foo', Time.now)

        assert_equal '{"token":"foo","expires_at":"1990-01-01T00:00:00-05:00"}', token.to_json
      end

      def test_to_s_and_to_str
        token = Token.new('foo', Time.now)

        assert_equal 'foo', token.to_s
        assert_equal 'foo', token.to_str
      end
    end
  end
end
