module MongoDB
  module Instrumentation
    class CommandSubscriber

      def initialize
        puts "new subscriber"
      end

      def started(topic, event)
        puts topic
        puts event
        puts "started"

      end

      def succeeded(topic, event)
        puts topic
        puts event
        puts "succeeded"

      end

      def failed(topic, event)
        puts topic
        puts event
        puts "failed"

      end

    end
  end
end
