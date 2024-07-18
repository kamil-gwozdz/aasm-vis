# frozen_string_literal: true

require_relative "lib/aasm/vis/version"

Gem::Specification.new do |spec|
  spec.name = "aasm-vis"
  spec.version = AASM::Vis::VERSION
  spec.authors = ["Kamil Gwóźdź"]
  spec.email = ["kamil@gwozdz.me"]

  spec.summary = "Gem for visualizing AASM state machines."
  spec.description = "Gem for visualising https://github.com/aasm/aasm state machines using markdown and https://github.com/mermaid-js/mermaid."
  spec.homepage = "https://github.com/kamil-gwozdz/aasm-vis"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kamil-gwozdz/aasm-vis"
  spec.metadata["changelog_uri"] = "https://github.com/kamil-gwozdz/aasm-vis/blob/main/CHANGELOG.md"

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

  spec.add_dependency "aasm", "~> 5"

  # TODO make it work without Rails
  spec.add_dependency "rake"
  spec.add_dependency "railties"
end
