require_relative '../vis/version'
require_relative '../vis'


module AASM
  module Vis
    class Railtie < Rails::Railtie
      railtie_name :my_gem

      rake_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end
    end
  end
end
