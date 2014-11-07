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
      command_opts["instance_ids"] = determine_instance_ids(options)
      command_opts.delete_if {|key,value| value.nil?}

      response = client.run_command('execute_recipes', command_args, command_opts)
      launch_stack_monitor(response, options)
    end
      
    def determine_instance_ids(options)
      if options[:instance_ids]
        options[:instance_ids]
      elsif options[:layers]
        determine_from_layers(options[:layers])
      elsif options[:ip_addresses]    
        determine_from_ips(options[:ip_addresses])
      elsif options[:eip]
        determine_from_eip
      end
    end

    def determine_from_ips(ips)
      if instances = Opsicle::Instances.find_by_ip(client, ips)  
        instances.map { |instance| instance[:instance_id] }
      else
        raise NoInstanceError, "Unable to find instances with given IP"
      end
    end

    def determine_from_eip
      if instance = Opsicle::Instances.find_by_eip(client).first
        instance[:instance_id] 
      else
        raise NoInstanceError, "Unable to find instances with elastic IPs"
      end
    end

    def determine_from_layers(layers)
      if instances = Opsicle::Layer.instance_ids(client, layers)
        instances
      else
        raise NoInstanceError, "Unable to find instances in specified layers"
      end
    end

    NoInstanceError = Class.new(StandardError)

  end
end
