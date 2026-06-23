# frozen_string_literal: true

require_relative "vis/version"

module AASM
  # Generates Mermaid state-diagram markdown for every AASM state machine
  # registered in the host application. Mix into a class and call
  # +generate_markdown+ (the rake task does this) or +build_diagrams+ to get the
  # markdown as a string.
  module Vis
    require_relative "vis/railtie" if defined?(Rails)

    class Error < StandardError; end

    # Writes the Mermaid markdown for the AASM state machines to +tmp/aasm-vis.md+.
    #
    # @param only [Array<String>, nil] class names to include; nil or empty
    #   generates every machine (the default).
    # @return [void]
    def generate_markdown(only: nil)
      Rails.application.eager_load! if defined?(Rails)

      path = File.join(Dir.pwd, "tmp", "aasm-vis.md")
      File.write(path, build_diagrams(only: only))
      puts "File written to: #{path}"
    end

    # Builds the Mermaid markdown for the AASM state machines.
    #
    # @param only [Array<String>, nil] class names to include; nil or empty
    #   includes every machine. Namespaced classes must be given in full
    #   (e.g. "Billing::Invoice").
    # @return [String] concatenated ```mermaid blocks, one per state machine.
    def build_diagrams(only: nil)
      filter = Array(only).map(&:to_s).reject(&:empty?)
      diagrams = []

      AASM::StateMachineStore.stores.each do |klass_name, klass_store|
        next unless included?(klass_name, filter)

        klass = klass_name.safe_constantize
        klass_store.machine_names.each { |column| diagrams << diagram_for(klass, column) }
      end

      diagrams.join("\n\n")
    end

    private

    # @return [Boolean] true when filter is empty (include all) or names this class.
    def included?(klass_name, filter)
      filter.empty? || filter.include?(klass_name.to_s)
    end

    # Builds a single ```mermaid stateDiagram-v2 block for one machine.
    #
    # Each transition is rendered as a labelled edge (+from --> to : event_name+)
    # so transitions between the same pair of states triggered by different
    # events stay distinguishable.
    #
    # @param klass [Class] the AASM-including class.
    # @param column [String] the state machine name (e.g. "state").
    # @return [String]
    def diagram_for(klass, column)
      machine = klass.aasm(column)
      transitions = collect_transitions(machine)

      <<~TXT
        ```mermaid
        ---
        title: #{klass}##{column}
        ---
        stateDiagram-v2

          #{state_nodes(machine).join("\n")}

          #{transition_edges(transitions).join("\n")}

          #{terminal_edges(transitions).join("\n")}
        ```
      TXT
    end

    # @return [Array<Array(Symbol, Symbol, Symbol)>] [from, to, event_name] tuples.
    def collect_transitions(machine)
      machine.events.flat_map do |event|
        event.transitions.map { |transition| [transition.from, transition.to, event.name] }
      end
    end

    # @return [Array<String>] +state_id : Display Name+ node declarations.
    def state_nodes(machine)
      machine.states.map { |state| "#{state.name} : #{state.default_display_name}" }
    end

    # @return [Array<String>] labelled +from --> to : event+ edges.
    def transition_edges(transitions)
      transitions.map { |from, to, name| "#{from.nil? ? "[*]" : from} --> #{to} : #{name}" }
    end

    # States that are never a transition source are terminal; link them to the
    # final pseudo-state.
    #
    # @return [Array<String>] +state --> [*]+ edges, de-duplicated.
    def terminal_edges(transitions)
      transitions.map { |_from, to, _name| "#{to} --> [*]" if transitions.none? { |t| t[0] == to } }
                 .compact.uniq
    end
  end
end
