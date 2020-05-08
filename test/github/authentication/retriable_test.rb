# frozen_string_literal: true
# # frozen_string_literal: true
require 'test_helper'

require "github/authentication/retriable"

module Github
  module Authentication
    class RetriableTest < Minitest::Test
      include Retriable

      ExpectedError = Class.new(StandardError)
      UnexpectedError = Class.new(StandardError)

      def test_with_retries_will_eventially_raise
        mock_object = mock
        mock_object.expects(:call).raises(ExpectedError.new('foo')).times(3)

        assert_raises(ExpectedError) do
          with_retries(ExpectedError, max_attempts: 3) do
            mock_object.call
          end
        end
      end

      def test_with_retries_will_succeed_and_return_the_final_return_value
        mock_object = mock
        mock_object.stubs(:call).raises(ExpectedError.new('foo'))
          .then.raises(ExpectedError.new('bar'))
          .then.returns("baz")

        return_value = with_retries(ExpectedError, max_attempts: 3) do
          mock_object.call
        end

        assert_equal "baz", return_value
      end

      def test_with_retries_does_not_sleep_between_attempts_when_sleep_between_attempts_0
        mock_object = mock
        mock_object.stubs(:call)
          .raises(ExpectedError.new('foo'))
          .then.raises(ExpectedError.new('bar'))
          .then.raises(ExpectedError.new('bar'))
          .then.raises(ExpectedError.new('bar'))
          .then.returns("baz")

        Kernel.expects(:sleep).never

        return_value = with_retries(ExpectedError, max_attempts: 5,
          sleep_between_attempts: 0, exponential_backoff: false) do
          mock_object.call
        end

        assert_equal "baz", return_value
      end

      def test_with_retries_sleeps_without_exponential_backoff_and_returns_the_final_return_value
        mock_object = mock
        mock_object.stubs(:call)
          .raises(ExpectedError.new('foo'))
          .then.raises(ExpectedError.new('bar'))
          .then.raises(ExpectedError.new('bar'))
          .then.raises(ExpectedError.new('bar'))
          .then.returns("baz")

        Kernel.expects(:sleep).with(2.0).times(4)

        return_value = with_retries(ExpectedError, max_attempts: 5,
          sleep_between_attempts: 2, exponential_backoff: false) do
          mock_object.call
        end

        assert_equal "baz", return_value
      end

      def test_with_retries_sleeps_with_exponential_backoff_default_and_returns_the_final_return_value
        mock_object = mock
        mock_object.stubs(:call)
          .raises(ExpectedError.new('foo'))
          .then.raises(ExpectedError.new('bar'))
          .then.raises(ExpectedError.new('bar'))
          .then.raises(ExpectedError.new('bar'))
          .then.returns("baz")

        sleep_sequence = sequence('sleep-sequence')
        Kernel.expects(:rand).with(2.0..2.0).returns(2.0).in_sequence(sleep_sequence)
        Kernel.expects(:sleep).with(2.0).in_sequence(sleep_sequence)

        Kernel.expects(:rand).with(2.0..4.0).returns(4.0).in_sequence(sleep_sequence)
        Kernel.expects(:sleep).with(4.0).in_sequence(sleep_sequence)

        Kernel.expects(:rand).with(2.0..8.0).returns(8.0).in_sequence(sleep_sequence)
        Kernel.expects(:sleep).with(8.0).in_sequence(sleep_sequence)

        Kernel.expects(:rand).with(2.0..16.0).returns(16.0).in_sequence(sleep_sequence)
        Kernel.expects(:sleep).with(16.0).in_sequence(sleep_sequence)

        return_value = with_retries(ExpectedError, max_attempts: 5, sleep_between_attempts: 2) do
          mock_object.call
        end

        assert_equal "baz", return_value
      end

      def test_with_retries_block_arguments
        exception = ExpectedError.new('foo')

        mock_object = mock
        mock_object.expects(:call).with(1, nil).raises(exception)
        mock_object.expects(:call).with(2, exception)

        with_retries(ExpectedError, max_attempts: 3) do |attempt, previous_failure|
          mock_object.call(attempt, previous_failure)
        end
      end

      def test_with_retries_raises_immediately_for_unexpected_exceptions
        exception = UnexpectedError.new('foo')

        mock_object = mock
        mock_object.expects(:call).raises(exception)

        assert_raises(UnexpectedError) do
          with_retries(ExpectedError, max_attempts: 3) do
            mock_object.call
          end
        end
      end
    end
  end
end
