# GithubAuthentication

This gem allows you to authenticate with GitHub. Specifically, as a [GitHub app](https://developer.github.com/apps/building-github-apps/creating-a-github-app/).

The app works well with the ActiveSupport::Cache, uses retries to mitigate GitHub flakiness, and is thread safe

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'github-authentication'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install github-authentication

## Usage

```ruby
require 'github/authentication'

cache = GithubAuthentication::Cache.new(storage: GithubAuthentication::ObjectCache.new)
generator = GithubAuthentication::Generator::App.new(pem: ENV['GITHUB_PEM'],
                                          installation_id: ENV['GITHUB_INSTALLATION_ID'],
                                          app_id: ENV['GITHUB_APP_ID'])
provider = GithubAuthentication::Provider.new(generator: generator, cache: cache)

provider.token
provider.reset_token
```

### Cache

The cache takes a storage argument. You can pass an instance of an `ActiveSupport::Cache` implementation or use the provided 
`GithubAuthentication::ObjectCache` if you are using it in a script.

### Generator::App

Generates a token for a GitHub app.

```ruby
GithubAuthentication::Generator::App.new(pem: ENV['GITHUB_PEM'],
                                          installation_id: ENV['GITHUB_INSTALLATION_ID'],
                                          app_id: ENV['GITHUB_APP_ID'])
```

### Generator::Personal

Mostly for testing purposes you can provide a github token that gets retrieved.
```ruby
GithubAuthentication::Generator::Personal.new(github_token: ENV['GITHUB_TOKEN'])
```

## Example

```ruby

require "base64"

module GitHub
  APP_ID = "<APP_ID>"
  INSTALLATION_ID = "<INSTALLATION_ID>"

  class << self
    def token
      @token_provider ||= begin
        if ENV['GITHUB_TOKEN']
          storage = GithubAuthentication::ObjectCache.new
          generator = GithubAuthentication::Generator::Personal.new(github_token: ENV['GITHUB_TOKEN'])
        else
          storage = ActiveSupport::Cache::RedisCacheStore.new
          pem = Base64.decode64(ENV['GITHUB_PEM'])
          generator = GithubAuthentication::Generator::App.new(pem: pem, installation_id: INSTALLATION_ID,
                                                                 app_id: APP_ID)
        end
        cache = GithubAuthentication::Cache.new(storage: storage)
        GithubAuthentication::Provider.new(generator: generator, cache: cache)
      end
      @token_provider.token
    end

    def client
      if ENV['GITHUB_TOKEN']
        Octokit::Client.new(access_token: token.to_s)
      else
        Octokit::Client.new(bearer_token: token.to_s)
      end
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shopify/github-authentication.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

