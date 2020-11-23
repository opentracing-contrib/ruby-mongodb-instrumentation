require 'spec_helper'

RSpec.describe MongoDB::Instrumentation::CommandSubscriber do
  describe "Class Methods" do
    it { should respond_to :started }
    it { should respond_to :succeeded }
    it { should respond_to :failed }
  end

  let (:tracer) { OpenTracingTestTracer.build }
  let (:subscriber) { MongoDB::Instrumentation::CommandSubscriber.new(tracer: tracer) }
  let (:start_event) { Mongo::Monitoring::Event::CommandStarted.new("test_started", "test_db", "127.0.0.1", 1, 1, "{}") }

  describe :started do
    before do
      subscriber.started(start_event)
    end

    it "adds a span for the event starting" do
      expect(subscriber.requests).to have_key 1
    end

    it "creates a new span" do
      expect(tracer.spans.count).to be 1
    end
  end

  describe :succeeded do
    let (:succeeded_event) { Mongo::Monitoring::Event::CommandSucceeded.new("test_success", "test_db", "127.0.0.1", 1, 1, "{}", 0) }
    let (:unstarted_event) { Mongo::Monitoring::Event::CommandSucceeded.new("unstarted_test_success", "test_db", "127.0.0.1", 2, 2, "{}", 0) }

    before do
      subscriber.started(start_event)
    end
    
    it "finishes a span if it exists" do
      subscriber.succeeded(succeeded_event)

      # the request key should be removed and a span should be added to the tracer
      expect(subscriber.requests).not_to have_key 1
      expect(tracer.spans.last.finished?).to be true
    end

    it "ignores request ids that haven't been started" do
      subscriber.succeeded(unstarted_event)

      expect(tracer.spans.last.finished?).to be false
    end
  end

  describe :failed do
    let (:failed_event) { Mongo::Monitoring::Event::CommandFailed.new("test_success", "test_db", "127.0.0.1", 1, 1, "error", "{}", 0) }
    let (:unstarted_event) { Mongo::Monitoring::Event::CommandFailed.new("unstarted_test_success", "test_db", "127.0.0.1", 2, 2, "error", "{}", 0) }

    before do
      subscriber.started(start_event)
    end

    it "finishes a span with error tag and message" do
      subscriber.failed(failed_event)

      # the key should be removed and the span finished
      expect(subscriber.requests).not_to have_key 1
      expect(tracer.spans.last.finished?).to be true

      # there should be an error tag and message log
      span = tracer.spans.last
      puts span.tags
      expect(span.tags["error"]).to be true
      expect(span.tags["sfx.error.message"]).to eq "error"
      expect(span.tags["sfx.error.kind"]).to eq "MongoDB::Instrumentation::Error"
    end

    it "ignores request ids that haven't been started" do
      subscriber.failed(unstarted_event)

      expect(tracer.spans.last.finished?).to be false
    end
  end
end
