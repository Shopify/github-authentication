# frozen_string_literal: true

module GithubAuthentication
  module GithubAPIHelper
    private

    def stub_create_installation_access_token(token: SecureRandom.hex)
      stub_request(:post, "https://api.github.com/app/installations/#{@installation_id}/access_tokens")
        .to_return(
          headers: { 'Content-Type' => 'application/json' },
          body: { token: token, expires_at: 1.hour.from_now.iso8601 }.to_json,
          status: 201,
        )
    end
  end
end
