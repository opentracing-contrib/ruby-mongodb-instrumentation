module MongoDB
  module Instrumentation
    class Error < StandardError
    end

    class CommandSubscriber

      attr_reader :requests

      def initialize(tracer: OpenTracing.global_tracer)
        @tracer = tracer

        @requests = {}
      end

      def started(event)
        # start command span
        tags = {
          # opentracing tags
          'component' => 'ruby-mongodb',
          'db.instance' => event.database_name,
          'db.statement' => event.command,
          'db.type' => 'mongo',
          'span.kind' => 'client',

          # extra info
          'mongo.command.name' => event.command_name,
          'mongo.operation.id' => event.operation_id,
          'mongo.request.id' => event.request_id,
        }
        span =@tracer.start_span(event.command_name, tags: tags)

        @requests[event.request_id] = span
      end

      def succeeded(event)
        return if @requests[event.request_id].nil?

        # tag the reported duration, in case it differs from what we saw
        # through the notifications times
        span = @requests[event.request_id]
        span.set_tag("took.ms", event.duration * 1000)

        span.finish()
        @requests.delete(event.request_id)
      end

      def failed(event)
        return if @requests[event.request_id].nil?

        # tag the reported duration and any error message that came through
        span = @requests[event.request_id]
        span.set_tag("took.ms", event.duration * 1000)
        error = Error.new(event.message) 
        span.record_exception(error)

        span.finish()
        @requests.delete(event.request_id)
      end
    end
  end
end
