## Git credential helper

The `github-authentication` gem bundles a [git credential helper][0] to
authenticate git operations as [GitHub Apps][1]. This is much preferred to
hard-coding long lived credentials like personal access tokens or SSH keys
inside e.g. a CI or build system.

For efficiency this helper requires the `activesupport` gem to allow for caching
credentials between git calls.

### Configuration

Token authentication is only supported over HTTPS, so as well as configuring the
credential helper we can also have git automatically rewrite SSH addresses. Add
this configuration snippet to `/etc/gitconfig` or `~/.gitconfig` depending on
your environment:

```
[url "https://github.com/"]
  insteadOf = git@github.com:
  insteadOf = ssh://git@github.com/
[credential "https://github.com"]
  useHttpPath = true
  helper = github-app
  # Or, if using bundler:
  # helper = !bundle exec git-credential-github-app
```

The credential helper also requires a few environment variables:

* `GITHUB_APP_ID` -> The App ID of the GitHub App
* `GITHUB_APP_INSTALLATION_ID` -> The Installation ID for the Org you want to
  access
* `GITHUB_APP_KEYFILE` -> Path to a [private key][2] generated for your app
* `GITHUB_APP_CREDENTIAL_STORAGE_PATH` -> Directory to store cached credentials,
  must already exist

[0]: https://git-scm.com/docs/gitcredentials
[1]: https://docs.github.com/en/developers/apps/getting-started-with-apps/about-apps
[2]: https://docs.github.com/en/developers/apps/building-github-apps/authenticating-with-github-apps#generating-a-private-key
