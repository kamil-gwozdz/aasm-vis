# frozen_string_literal: true

require "aasm"
# safe_constantize is provided by ActiveSupport, which Rails loads for us in a
# real app. Specs run without Rails, so require the inflections directly.
require "active_support/core_ext/string/inflections"
require "aasm/vis"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
