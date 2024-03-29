# frozen_string_literal: true

require_relative 'lib/solidus_mollie/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_mollie'
  spec.version = SolidusMollie::VERSION
  spec.authors = ['Victor ter Hark']
  spec.email = 'victor@afurastore.com'

  spec.summary = 'Accept payments through Mollie using Solidus Storefront'
  spec.homepage = 'https://github.com/afurastore/solidus_mollie'
  spec.license = 'BSD-3-Clause'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/[USERNAME]/solidus_mollie'
  spec.metadata['changelog_uri'] = 'https://github.com/[USERNAME]/solidus_mollie/releases'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.5')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'solidus_core', ['>= 2.0.0', '< 5']
  spec.add_dependency 'solidus_support', '~> 0.5'

  spec.add_runtime_dependency 'mollie-api-ruby', '~> 4.2.0'

  spec.add_development_dependency 'solidus_dev_support', '~> 2.5'
end
