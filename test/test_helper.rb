# frozen_string_literal: true
$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "github_authentication/provider"

require "minitest/autorun"

require 'timecop'
require 'mocha/minitest'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into(:webmock)
end

Mocha.configure do |c|
  c.stubbing_method_on_non_mock_object = :allow
  c.stubbing_method_unnecessarily = :prevent
  c.stubbing_method_on_nil = :prevent
  c.stubbing_non_existent_method = :prevent
end
