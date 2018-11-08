module MongoDB
  module Instrumentation
    class CommandSubscriber

      def initialize(tracer: OpenTracing.global_tracer)
        @tracer = tracer

        @requests = {}
      end

      def started(event)
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
      end

      def succeeded(event)
        # tag the reported duration, in case it differs from what we saw
        # through the notifications times
        span = @requests[event.request_id]
        span.set_tag("duration", event.duration)

        span.finish()
      end

      def failed(event)
        # tag the reported duration and any error message that came through
        span = @requests[event.request_id]
        span.tag("duration", event.duration)
        span.set_tag("error", true)
        span.log_kv("message", event.message)

        span.finish()
      end
    end
  end
end
