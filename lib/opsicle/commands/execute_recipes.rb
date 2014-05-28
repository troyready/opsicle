require "opsicle/deploy_helper"

module Opsicle
  class ExecuteRecipes
    include DeployHelper
    attr_reader :client, :recipes

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
    end

    def execute(options={ monitor: true })
      Output.say "Starting OpsWorks chef run..."

      #so this is how to format the command arguments:
      #http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/OpsWorks/Client.html#create_deployment-instance_method
      command_args = {}
      command_args["recipes"] = options[:recipes]

      command_opts = {}
      command_opts["instance_ids"] = options[:instance_ids] if options[:instance_ids]

      response = client.run_command('execute_recipes', command_args, command_opts)
      launch_stack_monitor(response, options)
    end
  end
end
