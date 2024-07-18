require_relative '../vis/version'
require_relative '../vis'

module AASM
  module Vis

    module Task
      extend Rake::DSL

      namespace :aasm_vis do
        desc 'Generate markdown file with visualisation of AASM state machines.'

        task :generate do
          helper = Helper.new
          helper.generate_markdown
        end
      end

      class Helper
        include AASM::Vis
      end
    end
  end
end
