# frozen_string_literal: true

require 'net/http'
require 'timeout'

require 'github_authentication/retriable'

module GithubAuthentication
  module Http
    class << self
      include Retriable

      def post(url)
        uri = URI.parse(url)
        with_retries(SystemCallError, Timeout::Error) do
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.start
          begin

            request = Net::HTTP::Post.new(uri.request_uri)
            yield(request) if block_given?

            http.request(request)
          ensure
            http.finish
          end
        end
      end
    end
  end
end
