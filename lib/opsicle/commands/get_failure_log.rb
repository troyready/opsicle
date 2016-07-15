# require "opsicle/deploy_helper"

module Opsicle
  class GetFailureLog
    # include DeployHelper
    attr_reader :client

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
    end

    def execute(options={ monitor: true })
      Output.say "Getting most recent failure log..."

      # do something here
    end
  end
end
