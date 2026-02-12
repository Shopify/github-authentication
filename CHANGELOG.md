### Next

...

### 1.3.2
- Add missing requires for active_support/cache to environment.rb

### 1.3.1
- Fixed active_support to be a runtime dependency, not a development dependency

### 1.3.0
- Add `GithubAuthentication.provider(org:, env:)` as a high-level entrypoint for Ruby code that needs GitHub App tokens without manually wiring up Environment, Generator, Cache, and Provider
- Simplify `GitCredentialHelper` to accept a `provider` directly
- Update test runners to test against more recent Ruby versions

### 1.2.0
- Support multi-org credentials (https://github.com/Shopify/github-authentication/pull/34)
