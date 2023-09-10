# frozen_string_literal: true

require_relative "lib/constant_vision/version"

Gem::Specification.new do |spec|
  spec.name = "constant_vision"
  spec.version = ConstantVision::VERSION
  spec.authors = ["hogucc"]
  spec.email = ["uku.h1r8@gmail.com"]

  spec.summary = "constant_vision"
  spec.description = "The ConstantVision gem is designed to scan all constants within a Rails application. It is useful for finding out if a constant exists or not."
  spec.homepage = "https://github.com/hogucc/constant_vision"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hogucc/constant_vision"
  spec.metadata["changelog_uri"] = "https://github.com/hogucc/constant_vision"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
