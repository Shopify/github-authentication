# frozen_string_literal: true
$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "github/authentication/provider"

require "minitest/autorun"

require 'timecop'
require 'mocha/minitest'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into(:webmock)
end
