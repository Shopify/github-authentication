
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "github/authentication/version"

Gem::Specification.new do |spec|
  spec.name          = "github-authentication"
  spec.version       = Github::Authentication::VERSION
  spec.authors       = ["Frederik Dudzik"]
  spec.email         = ["frederik.dudzik@shopify.com"]

  spec.summary       = "GitHub authetication"
  spec.description   = "Authenticate with GitHub"
  spec.homepage      = "https://github.com/Shopify/github-authentication"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/Shopify/github-authentication"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "jwt", "~> 2.2"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "mocha", "~> 1.11"
  spec.add_development_dependency "webmock", "~> 3.8"
  spec.add_development_dependency "vcr", "~> 5.1"
end
