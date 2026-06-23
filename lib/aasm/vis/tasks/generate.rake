# frozen_string_literal: true

class Helper
  include AASM::Vis
end

namespace :aasm_vis do
  desc "Generate markdown file with visualisation of AASM state machines. " \
       "Optionally limit to specific classes, e.g. aasm_vis:generate[Job,Order]."

  dependencies = defined?(Rails) ? [:environment] : []
  task :generate, [:only] => dependencies do |_task, args|
    Helper.new.generate_markdown(only: args.to_a)
  end
end
