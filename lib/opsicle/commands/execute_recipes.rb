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
      if options[:instance_ids] || options[:layers]
        command_opts["instance_ids"] = options[:instance_ids] ? options[:instance_ids] : instance_ids(options[:layers])
      end

      response = client.run_command('execute_recipes', command_args, command_opts)
      launch_stack_monitor(response, options)
    end

    def get_layer_ids(layers)
      client.api_call('describe_layers')[:layers].map{ |s| s[:id] if layers.include?(s[:name]) }.compact 
    end

    def get_instance_ids(layer_id)
      client.api_call('describe_instances', layer_id: layer_id)[:instances].map{ |s| s[:instance_id] }
    end

    def instance_ids(layers)
      get_layer_ids(layers).map{ |layer_id| get_instance_ids(layer_id)[0] }
    end

  end
end
