# frozen_string_literal: true

require 'jwt'
require "uri"
require 'openssl'

module Github
  module Authentication
    module Generator
      class App
        attr_reader :app_id, :installation_id

        def initialize(pem:, installation_id:, app_id:)
          @private_key = OpenSSL::PKey::RSA.new(pem)
          @installation_id = installation_id
          @app_id = app_id
        end

        def generate
          url = "https://api.github.com/app/installations/#{installation_id}/access_tokens"
          response = Http.post(url) do |request|
            request["Authorization"] = "Bearer #{jwt}"
            request["Accept"] = "application/vnd.github.machine-man-preview+json"
            request
          end
          Token.from_json(response.body)
        end

        private

        def jwt
          payload = {
            # issued at time
            iat: Time.now.to_i,
            # JWT expiration time (10 minute maximum)
            exp: Time.now.to_i + (10 * 60),
            # GitHub App's identifier
            iss: app_id,
          }
          JWT.encode(payload, @private_key, "RS256")
        end
      end
    end
  end
end
