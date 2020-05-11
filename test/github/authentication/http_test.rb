# frozen_string_literal: true
require 'test_helper'

require "github/authentication/http"

module Github
  module Authentication
    class HttpTest < Minitest::Test
      def test_makes_http_call
        VCR.use_cassette('make_http_call') do
          result = Http.post('https://postman-echo.com/post?hand=wave')

          assert_equal({ "hand" => "wave" }, JSON.parse(result.body)['args'])
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

      def test_retries_http_calls
        bad_http = mock_net_http
        good_http = mock_net_http

        bad_http.expects(:request).raises(Errno::ECONNREFUSED)
        good_http.expects(:request).returns(Net::HTTPOK.new('1.1', '200', 'OK'))

        Net::HTTP.stubs(:new).with('example.com', 443).returns(bad_http).then.returns(good_http)
        result = Http.post('https://example.com/foo')
        assert_kind_of Net::HTTPOK, result
      end

      private

      def mock_net_http
        http = Net::HTTP.new('example.com', 443)
        http.stubs(:start)
        http.stubs(:finish)
        http
      end
    end
  end
end
