require "opsicle/deploy_helper"

module Opsicle
  class Deploy
    include DeployHelper
    attr_reader :client

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
    end

    def execute(options={ monitor: true })
      Output.say "Starting OpsWorks deploy..."

      #so this is how to format the command arguments:
      #http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/OpsWorks/Client.html#create_deployment-instance_method
      command_args = {}
      command_args["migrate"] = [options[:migrate].to_s] if options[:migrate]
      response = client.run_command('deploy', command_args)

      launch_stack_monitor(response, options)
    end
  end
end
