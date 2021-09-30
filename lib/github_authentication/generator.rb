# frozen_string_literal: true

require "github_authentication/generator/app"
require "github_authentication/generator/personal"

module GithubAuthentication
  module Generator
    Error = Class.new(StandardError)
    TokenGeneratorError = Class.new(Error)
  end
end
