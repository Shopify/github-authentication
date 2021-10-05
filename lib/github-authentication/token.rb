# frozen_string_literal: true

require 'json'

module GithubAuthentication
  class Token
    attr_reader :expires_at

    def self.from_json(data)
      return nil if data.nil?

      token, expires_at = JSON.parse(data).values_at('token', 'expires_at')
      new(token, Time.iso8601(expires_at))
    rescue JSON::ParserError
      nil
    end

    def initialize(token, expires_at)
      @token = token
      @expires_at = expires_at
    end

    def expires_in
      (@expires_at - Time.now.utc).to_i
    end

    def expired?(seconds_ttl: 300)
      @expires_at < Time.now.utc + seconds_ttl
    end

    def valid_for?(ttl)
      !expired?(seconds_ttl: ttl)
    end

    def inspect
      # Truncating the token should be enough not to leak it in error messages etc
      "#<#{self.class.name} @token=#{truncate(@token, 10)} @expires_at=#{@expires_at}>"
    end

    def to_json
      JSON.dump(token: @token, expires_at: @expires_at.iso8601)
    end

    def to_s
      @token
    end
    alias_method :to_str, :to_s

    private

    def truncate(string, max)
      string.length > max ? "#{string[0...max]}..." : string
    end
  end
end
