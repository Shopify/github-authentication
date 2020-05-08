# frozen_string_literal: true
require 'test_helper'

require 'github/authentication/cache'

module Github
  module Authentication
    class CacheTest < Minitest::Test
      def setup
        Timecop.freeze("1990-01-01T00:00:00Z")
        @key = "github:authentication:foo"
      end

      def teardown
        Timecop.return
      end

      def test_read_from_cache
        storage = mock()
        storage.stubs(:read).with(@key).returns('{"token":"foo","expires_at":"1990-01-01T00:00:00Z"}')
        cache = Cache.new(key: 'foo', storage: storage)

        token = cache.read

        assert_equal('foo', token.to_s)
        assert_equal(0, token.expires_in)
      end

      def test_write_to_cache
        storage = mock
        storage.stubs(:write)
          .with(@key, '{"token":"foo","expires_at":"1990-01-01T00:00:00Z"}', expires_in: 0)
        cache = Cache.new(key: 'foo', storage: storage)
        token = Token.new('foo', Time.now.utc)

        cache.write(token)
      end

      def test_clear_cache
        storage = mock
        storage.stubs(:delete).with(@key)
        cache = Cache.new(key: 'foo', storage: storage)

        cache.clear
      end
    end
  end
end
