# frozen_string_literal: true

# A plain AASM class (no ActiveRecord) used to exercise diagram generation.
# Defining it registers the machine in AASM::StateMachineStore, which is what
# build_diagrams walks. Two events (succeed, error) leave the same state so we
# can assert that labelled edges keep them distinguishable.
class Job
  include AASM

  aasm :state do
    state :created, initial: true
    state :running
    state :finished_successfully
    state :finished_with_error

    event :run do
      transitions from: :created, to: :running
    end

    event :succeed do
      transitions from: :running, to: :finished_successfully
    end

    event :error do
      transitions from: :running, to: :finished_with_error
    end
  end
end

# A second machine, used to assert that model selection includes/excludes the
# right diagrams.
class Order
  include AASM

  aasm :status do
    state :draft, initial: true
    state :placed

    event :place do
      transitions from: :draft, to: :placed
    end
  end
end

RSpec.describe AASM::Vis do
  subject(:markdown) { helper.build_diagrams }

  let(:helper) { Class.new { include AASM::Vis }.new }

  it "has a version number" do
    expect(AASM::Vis::VERSION).not_to be_nil
  end

  it "titles the diagram with the class and machine column" do
    expect(markdown).to include("title: Job#state")
  end

  it "renders each state node with its humanized display name" do
    expect(markdown).to include("created : Created")
    expect(markdown).to include("finished_successfully : Finished successfully")
  end

  it "labels each transition edge with the triggering event name" do
    expect(markdown).to include("created --> running : run")
    expect(markdown).to include("running --> finished_successfully : succeed")
    expect(markdown).to include("running --> finished_with_error : error")
  end

  it "keeps edges leaving the same state distinguishable by event label" do
    # Both succeed and error leave `running`; without labels these collapse into
    # two identical `running --> ...` lines. The labels are what separate them.
    succeed_edge = "running --> finished_successfully : succeed"
    error_edge = "running --> finished_with_error : error"
    expect(markdown).to include(succeed_edge).and include(error_edge)
  end

  it "marks states with no outgoing transition as terminal" do
    expect(markdown).to include("finished_successfully --> [*]")
    expect(markdown).to include("finished_with_error --> [*]")
  end
end

RSpec.describe AASM::Vis, "model selection via only:" do
  let(:helper) { Class.new { include AASM::Vis }.new }

  it "generates every machine when only is nil (the default)" do
    expect(helper.build_diagrams).to include("title: Job#state").and include("title: Order#status")
  end

  it "generates every machine when only is empty" do
    result = helper.build_diagrams(only: [])
    expect(result).to include("title: Job#state").and include("title: Order#status")
  end

  it "limits output to the named classes" do
    result = helper.build_diagrams(only: %w[Order])
    expect(result).to include("title: Order#status")
    expect(result).not_to include("title: Job#state")
  end

  it "accepts multiple class names" do
    result = helper.build_diagrams(only: %w[Job Order])
    expect(result).to include("title: Job#state").and include("title: Order#status")
  end

  it "produces no diagrams when no named class matches" do
    expect(helper.build_diagrams(only: %w[Nonexistent])).to eq("")
  end
end
