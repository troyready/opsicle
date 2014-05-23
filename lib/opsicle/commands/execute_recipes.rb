require "opsicle/deploy_helper"

module Opsicle
  class ExecuteRecipes
    include DeployHelper
    attr_reader :client, :recipes

    def initialize(environment, *recipes)
      @environment = environment
      @client = Client.new(environment)
      @recipes = recipes
    end

    def execute(options={ monitor: true })
      Output.say "Starting OpsWorks chef run..."

      #so this is how to format the command arguments:
      #http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/OpsWorks/Client.html#create_deployment-instance_method
      command_args = {}
      command_args["recipes"] = recipes
      response = client.run_command('execute_recipes', command_args)

      launch_stack_monitor(response, options)
    end
  end
end
