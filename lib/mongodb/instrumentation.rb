require "mongodb/instrumentation/version"
require "mongodb/instrumentation/command_subscriber"

module MongoDB
  module Instrumentation

    class << self

      def instrument(**args)

        Mongo::Monitoring::Global.subscribe(Mongo::Monitoring::COMMAND, MongoDB::Instrumentation::CommandSubscriber.new)
      end
    end
  end
end
