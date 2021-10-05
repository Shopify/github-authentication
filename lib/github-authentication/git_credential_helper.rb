# frozen_string_literal: true

module GithubAuthentication
  class GitCredentialHelper
    def initialize(pem:, installation_id:, app_id:, storage: nil, stdin: $stdin)
      @pem = pem
      @installation_id = installation_id
      @app_id = app_id
      @storage = storage
      @stdin = stdin
    end

    def handle_get
      description = parse_stdin

      unless description['protocol'] == 'https' && description['host'] == 'github.com'
        warn("Unsupported description: #{description}")
        return 2
      end

      token = provider.token(seconds_ttl: min_cache_ttl)
      puts("password=#{token}")
      puts('username=api')

      0
    end

    private

    def min_cache_ttl
      # Tokens are valid for 60 minutes, allow a 10 minute buffer
      10 * 60
    end

    def parse_stdin
      # Credential description is written to STDIN in line delimited key=value form,
      # see https://git-scm.com/docs/git-credential#IOFMT
      @stdin.each_line.map { |line| line.split('=', 2).map(&:strip) }.to_h
    end

    def provider
      @provider ||= Provider.new(
        generator: generator,
        cache: Cache.new(storage: @storage || ObjectCache.new)
      )
    end

    def generator
      @generator ||= Generator::App.new(
        pem: @pem,
        app_id: @app_id,
        installation_id: @installation_id
      )
    end
  end
end
