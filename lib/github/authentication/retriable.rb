# frozen_string_literal: true

module Github
  module Authentication
     module Retriable
        def with_retries(*exceptions, max_attempts: 4, sleep_between_attempts: 0.1, exponential_backoff: true)
          attempt = 1
          previous_failure = nil

          begin
            return_value = yield attempt, previous_failure
          rescue *exceptions => exception
            raise unless attempt < max_attempts

            sleep_after_attempt(
              attempt: attempt,
              base_sleep_time: sleep_between_attempts,
              exponential_backoff: exponential_backoff
            )

            attempt += 1
            previous_failure = exception
            retry
          else
            return_value
          end
        end

        private

        def sleep_after_attempt(attempt:, base_sleep_time:, exponential_backoff:)
          return unless base_sleep_time > 0

          time_to_sleep = if exponential_backoff
            calculate_exponential_backoff(attempt: attempt, base_sleep_time: base_sleep_time)
          else
            base_sleep_time
          end

          Kernel.sleep(time_to_sleep)
        end

        def calculate_exponential_backoff(attempt:, base_sleep_time:)
          # Double the max sleep time for every attempt (exponential backoff).
          # Randomize sleep time for more optimal request distribution.
          lower_bound = Float(base_sleep_time)
          upper_bound = lower_bound * (2 << (attempt - 2))
          Kernel.rand(lower_bound..upper_bound)
        end
     end
  end
end
