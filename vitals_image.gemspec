# coding: utf-8
# frozen_string_literal: true

require_relative "lib/vitals_image/version"

Gem::Specification.new do |spec|
  spec.name          = "vitals_image"
  spec.version       = VitalsImage::VERSION::STRING
  spec.authors       = ["Breno Gazzola"]
  spec.email         = ["breno@festalab.com"]

  spec.summary       = "Image tags that conform with web vitals"
  spec.homepage      = "https://github.com/FestaLab/vitals_image"
  spec.license       = "MIT"

  # spec.metadata["allowed_push_host"] = "http://rubygems.org"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/FestaLab/vitals_image"
  spec.metadata["changelog_uri"]   = "https://github.com/FestaLab/vitals_image/CHANGELOG.mg"

  spec.files         = Dir["{app,config,db,lib}/**/*", "Rakefile", "MIT-LICENSE", "README.md""CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.add_dependency "activejob",      [">= 6.1.3.1", "< 7.0"]
  spec.add_dependency "activemodel",    [">= 6.1.3.1", "< 7.0"]
  spec.add_dependency "activerecord",   [">= 6.1.3.1", "< 7.0"]
  spec.add_dependency "activestorage",  [">= 6.1.3.1", "< 7.0"]
  spec.add_dependency "activesupport",  [">= 6.1.3.1", "< 7.0"]
  spec.add_dependency "mini_magick",    [">= 4.9.5", "< 5"]
  spec.add_dependency "ruby-vips",      ["2.0.17"] # 2.10 is bugged with vips 8.9 which is the one available in Ubuntu 20.04
  spec.add_dependency "platform_agent"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-packaging"
  spec.add_development_dependency "rubocop-rails"
end
