# typed: true
# frozen_string_literal: true

require 'net/http'

require 'github/authentication/retriable'

module Github
  module Authentication
    module Http
      class << self
        include Retriable

        def post(url)
          uri = URI.parse(url)
          unless uri.is_a?(URI::HTTP)
            raise ArgumentError, "Only HTTP URIs are supported"
          end

          result = with_retries(Errno::ECONNREFUSED, Net::ReadTimeout) do
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.start

            begin
              request = Net::HTTP::Post.new(uri.request_uri)
              yield request if block_given?
              http.request(request)
            ensure
              http.finish
            end
          end

          result
        end
      end
    end
  end
end
