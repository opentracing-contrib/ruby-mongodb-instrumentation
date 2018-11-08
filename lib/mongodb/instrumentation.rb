require "mongodb/instrumentation/version"
require "mongodb/instrumentation/command_subscriber"
require "opentracing"

module MongoDB
  module Instrumentation
    class << self
      def instrument(tracer: OpenTracing.global_tracer)
        Mongo::Monitoring::Global.subscribe(Mongo::Monitoring::COMMAND, MongoDB::Instrumentation::CommandSubscriber.new(tracer: tracer))
      end
    end
  end
end
