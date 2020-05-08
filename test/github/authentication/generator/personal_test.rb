# frozen_string_literal: true
require 'test_helper'

require "github/authentication/generator/personal"

module Github
  module Authentication
    module Generator
      class PersonalTest < Minitest::Test
        def setup
          Timecop.freeze("1990-01-01T00:00:00Z")
        end

        def after
          Timecop.return
        end

        def test_generate
          generator = Personal.new(github_token: 'foo')

          token = generator.generate

          assert_equal '1991-01-01T05:49:12Z', token.expires_at.iso8601
          assert_equal 'foo', token.to_s
        end
      end
    end
  end
end
