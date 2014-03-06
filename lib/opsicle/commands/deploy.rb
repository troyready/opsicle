module Opsicle
  class Deploy
    attr_reader :client

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
    end

    def execute(options={ monitor: true })
      Output.say "Starting OpsWorks deploy..."
      response = client.run_command('deploy')

      # Monitoring preferences
      if options[:browser]
        open_deploy(response[:deployment_id])
      elsif options[:monitor] # Default option
        Output.say_verbose "Starting Stack Monitor..."
        @monitor = Opsicle::Monitor::App.new(@environment, options)
        @monitor.start
      end

    end

    def open_deploy(deployment_id)
      if deployment_id
        command = "open 'https://console.aws.amazon.com/opsworks/home?#/stack/#{client.config.opsworks_config[:stack_id]}/deployments'"
        Output.say_verbose "Executing shell command: #{command}"
        %x(#{command})
      else
        Output.say "Deploy failed. No deployment_id was received from OpsWorks", "RED"
      end
    end
  end
end
