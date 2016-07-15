require "opsicle/get_failure_log_helper"

module Opsicle
  class GetFailureLog
    include GetFailureLogHelper
    attr_reader :client, :stack

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
      @stack = Opsicle::Stack.new(@client)
    end

    def execute
      puts "Getting most recent failure log..."

      get_recent_failure_log(@client, @stack)
    end
  end
end
