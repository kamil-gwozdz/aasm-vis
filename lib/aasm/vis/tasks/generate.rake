class Helper
  include AASM::Vis
end

namespace :aasm_vis do
  desc 'Generate markdown file with visualisation of AASM state machines.'

  task :generate do
    helper = Helper.new
    helper.generate_markdown
  end
end
