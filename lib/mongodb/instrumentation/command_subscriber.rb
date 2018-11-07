require 'pp'
require 'opentracing'
module MongoDB
  module Instrumentation
    class CommandSubscriber

      @operations

      def initialize(tracer: tracer)
        @tracer = tracer

        @requests = {}
      end

      def started(event)
        # todo how to handle operations and multiple operations per 

        # start command span
        tags = {
          # opentracing tags
          'component' => 'mongodb-instrumentation',
          'db.instance' => event.database_name,
          'db.statement' => event.command,
          'db.type' => 'mongo',
          'span.kind' => 'client',

          # extra info
          'command_name' => event.command_name,
          'operation_id' => event.operation_id,
          'request_id' => event.request_id,
        }
        span =@tracer.start_span(event.command_name, tags: tags)

        @requests[event.request_id] = span
        
        puts ""
        puts event.command
        puts "#{event.operation_id} #{event.request_id}"
        puts "started"
      end

      def succeeded(event)
        span = @requests[event.request_id]
        span.finish()

        puts event.duration
        puts event.reply
        puts "#{event.operation_id} #{event.request_id}"
        puts "succeeded"
      end

      def failed(event)
        span = @requests[event.request_id]

        span.set_tag("error", true)
        span.finish()

        puts event.duration
        puts event.reply
        puts "#{event.operation_id} #{event.request_id}"
        puts "failed"
      end

      private
      def finish_span(event, tags)
      end

    end
  end
end
