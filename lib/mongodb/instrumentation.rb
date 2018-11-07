require "mongodb/instrumentation/version"
require "mongodb/instrumentation/command_subscriber"

require "opentracing"

module MongoDB
  module Instrumentation

    class << self

      attr_accessor :tracer

      def instrument(tracer: nil)
        @tracer = tracer || OpenTracing.global_tracer

        Mongo::Monitoring::Global.subscribe(Mongo::Monitoring::COMMAND, MongoDB::Instrumentation::CommandSubscriber.new(@tracer))
      end
    end
  end
end
