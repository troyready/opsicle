module Opsicle
  class Deploy
    attr_reader :client

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
    end

    def execute(options={ monitor: true })
      say "<%= color('Starting OpsWorks deploy...', YELLOW) %>"
      response = client.run_command('deploy')

      # Monitoring preferences
      if options[:browser] == true
        open_deploy(response[:deployment_id])
      elsif options[:monitor] == true # Default option
        say "<%= color('Starting Stack Monitor...', MAGENTA) %>" if $verbose
        @monitor = Opsicle::Monitor::App.new(@environment, options)
        @monitor.start
      end

    end

    def open_deploy(deployment_id)
      if deployment_id
        command = "open 'https://console.aws.amazon.com/opsworks/home?#/stack/#{client.config.opsworks_config[:stack_id]}/deployments'"
        say "<%= color('Executing shell command: #{command}', MAGENTA) %>" if $verbose
        %x(#{command})
      else
        say "<%= color('Deploy failed. No deployment_id was received from OpsWorks', RED) %>"
      end
    end
  end
end
