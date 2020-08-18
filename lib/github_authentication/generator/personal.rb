# frozen_string_literal: true

require "github_authentication/token"

module GithubAuthentication
  module Generator
    class Personal
      def initialize(github_token:)
        @github_token = github_token
      end

      def generate
        a_year_from_now = Time.now.utc + 31_556_952
        Token.new(@github_token, a_year_from_now)
      end
    end
  end
end
