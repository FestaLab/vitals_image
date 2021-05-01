# frozen_string_literal: true

require_relative "lib/vitals_image/version"

Gem::Specification.new do |spec|
  spec.name          = "vitals_image"
  spec.version       = VitalsImage::VERSION
  spec.authors       = ["Breno Gazzola"]
  spec.email         = ["breno.gazzola@gmail.com"]

  spec.summary       = "Image tags that conform with web vitals"
  spec.description   = "Vitals Image is a lib that make it easier to create image tags that follow best practices for fast loading web pages"
  spec.homepage      = "https://github.com/FestaLab/vitals_image"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["allowed_push_host"] = "http://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/FestaLab/vitals_image"
  spec.metadata["changelog_uri"] = "https://github.com/FestaLab/vitals_image/CHANGELOG.mg"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "ruby-vips", ">= 2.0.17"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
