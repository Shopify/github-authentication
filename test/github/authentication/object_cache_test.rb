# frozen_string_literal: true
require 'test_helper'

require 'github/authentication/object_cache'

module Github
  module Authentication
    class ObjectCacheTest < Minitest::Test
      def setup
        Timecop.freeze("1990-01-01T00:00:00Z")
        @key = "github:authentication:foo"
      end

      def teardown
        Timecop.return
      end

      def test_read_from_cache_returns_nil_if_not_written
        cache = ObjectCache.new

        result = cache.read('foo')

        assert_nil result
      end

      def test_read_from_cache_returns_nil_if_expired
        cache = ObjectCache.new

        cache.write('foo', 'bar', expires_in: 10)
        Timecop.freeze(Time.now + 11*60) do
          result = cache.read('foo')

          assert_nil result
        end
      end

      def test_read_from_cache_is_not_expired
        cache = ObjectCache.new

        cache.write('foo', 'bar', expires_in: 10)
        Timecop.freeze(Time.now + 9*60) do
          result = cache.read('foo')

          assert_equal 'bar', result
        end
      end

      def test_read_from_cache_is_not_expired_2
        cache = ObjectCache.new

        cache.write('foo', 'bar')
        Timecop.freeze(Time.now + 100*60) do
          result = cache.read('foo')

          assert_equal 'bar', result
        end
      end
    end
  end
end

