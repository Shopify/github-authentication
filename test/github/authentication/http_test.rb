# frozen_string_literal: true
require 'test_helper'

require "github/authentication/http"

module Github
  module Authentication
    class HttpTest < Minitest::Test
      def test_makes_http_call
        VCR.use_cassette('make_http_call') do
          result = Http.post('https://postman-echo.com/post?hand=wave')

          assert_equal({"hand"=>"wave"}, JSON.parse(result.body)['args'])
        end
      end

      def test_http_call_with_changed_request_header
        VCR.use_cassette('make_http_call_with_changed_request_header') do
          result = Http.post('https://postman-echo.com/post?hand=wave') do |request|
            request['Content-Type'] = 'application/json'
          end

          assert_equal('application/json', JSON.parse(result.body).dig('headers', 'content-type'))
        end
      end
    end
  end
end
