require 'spec_helper'

RSpec.describe MongoDB::Instrumentation do
  describe "Class Methods" do
    it { should respond_to :instrument }
  end

  describe :instrument do

    before do
      MongoDB::Instrumentation.instrument
    end

    it "subscribes to COMMAND events" do
      expect(Mongo::Monitoring::Global.subscribers? Mongo::Monitoring::COMMAND).to be(true)
    end
  end
end
