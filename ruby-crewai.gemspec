# frozen_string_literal: true

require_relative "lib/crewai/version"

Gem::Specification.new do |spec|
  spec.name = "ruby-crewai"
  spec.version = CrewAI::VERSION
  spec.authors = ["Muhammad Ibtisam Hussain"]
  spec.email = ["78165374+MuhammadIbtisam@users.noreply.github.com"]

  spec.summary = "Ruby client for the CrewAI AMP HTTP API"
  spec.description = "A minimal, production-grade Ruby client for CrewAI AMP REST endpoints: inputs, kickoff, status, and resume."
  spec.homepage = "https://github.com/MuhammadIbtisam/ruby-crewai"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*.rb", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 2.0", "< 3"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
