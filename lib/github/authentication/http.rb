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
          http = nil

          result = with_retries(Errno::ECONNREFUSED, Net::ReadTimeout) do
            unless http
              http = Net::HTTP.new(uri.host, uri.port)
              http.use_ssl = true
              http.start
            end
            request = Net::HTTP::Post.new(uri.request_uri)
            yield(request) if block_given?
            http.request(request)
          end

          http&.finish
          result
        end
      end
    end
  end
end
