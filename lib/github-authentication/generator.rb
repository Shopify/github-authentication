# frozen_string_literal: true

require "github-authentication/generator/app"
require "github-authentication/generator/personal"

module GithubAuthentication
  module Generator
    Error = Class.new(StandardError)
    TokenGeneratorError = Class.new(Error)
  end
end
