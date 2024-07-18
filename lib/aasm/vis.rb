# frozen_string_literal: true

require_relative "vis/version"

module AASM
  module Vis
    require_relative 'vis/railtie' if defined?(Rails)

    class Error < StandardError; end

    def generate_markdown
      begin
        Rails.application.eager_load!
      rescue
        # not using rails
      end

      results = []

      AASM::StateMachineStore.stores.each do |klass_name, klass_store|
        klass_store.keys.each do |column|
          transitions = []
          klass = klass_name.safe_constantize
          klass.aasm(column).events.each do |event|
            event.name
            event.default_display_name

            event.transitions.each do |transition|
              transitions << [transition.from, transition.to]
            end
          end

          results << <<~TXT
            ```mermaid
            ---
            title: #{klass}##{column}
            ---
            stateDiagram-v2
            
              #{klass.aasm(column).states.map { |state| "#{state.name} : #{state.default_display_name}" }.join("\n") }
            
              #{transitions.map { |from, to| "#{from.nil? ? "[*]" : from } --> #{to}" }.join("\n") }
            ```
          TXT
        end
      end

      path = File.join(Dir.pwd,'tmp', 'assm-vis.md')
      results = results.join("\n\n")

      File.write(path, results)
      puts "File written to: #{path}"
    end
  end
end
