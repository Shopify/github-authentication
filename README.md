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

The simplest way to get a GitHub App token is via `GithubAuthentication.provider`, which reads credentials from environment variables, handles JWT generation, token exchange, and caching:

```ruby
require 'github-authentication'

provider = GithubAuthentication.provider(org: "myorg")
provider.token # => returns a cached or freshly generated token
```

This expects the following environment variables to be set (optionally prefixed with the org name):

- `GITHUB_APP_ID` (or `MYORG_GITHUB_APP_ID`)
- `GITHUB_APP_INSTALLATION_ID` (or `MYORG_GITHUB_APP_INSTALLATION_ID`)
- `GITHUB_APP_KEYFILE` (or `MYORG_GITHUB_APP_KEYFILE`)

If `GITHUB_APP_CREDENTIAL_STORAGE_PATH` is set, tokens are cached to disk via `ActiveSupport::Cache::FileStore`. Otherwise an in-memory cache is used.

### Using with Octokit

```ruby
provider = GithubAuthentication.provider(org: "myorg")
client = Octokit::Client.new(access_token: provider.token.to_s)
```

### Building a provider manually

If you need more control over the cache or generator, you can wire up the components yourself:

```ruby
cache = GithubAuthentication::Cache.new(storage: GithubAuthentication::ObjectCache.new)
generator = GithubAuthentication::Generator::App.new(pem: ENV['GITHUB_PEM'],
                                          installation_id: ENV['GITHUB_INSTALLATION_ID'],
                                          app_id: ENV['GITHUB_APP_ID'])
provider = GithubAuthentication::Provider.new(generator: generator, cache: cache)

provider.token
provider.reset_token
```

### Generator::Personal

Mostly for testing purposes you can provide a github token that gets retrieved.
```ruby
GithubAuthentication::Generator::Personal.new(github_token: ENV['GITHUB_TOKEN'])
```

## Git credential helper

This gem also ships with a [git credential helper][0] to authenticate git
operations as an App. See [this doc](docs/github_credential_helper.md) for
detail on setup and configuration.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shopify/github-authentication.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[0]: https://git-scm.com/docs/gitcredentials
