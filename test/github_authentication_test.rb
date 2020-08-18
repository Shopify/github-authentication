# frozen_string_literal: true

require "test_helper"

require "github_authentication"

class AuthenticationTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::GithubAuthentication::VERSION
  end
end
