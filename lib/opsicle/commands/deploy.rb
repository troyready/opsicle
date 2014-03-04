module Opsicle
  class Deploy
    attr_reader :client

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
    end

    def execute(options={})
      response = client.run_command('deploy')

      if options[:browser]
        open_deploy(response[:deployment_id])
      end

      if options[:monitor]
        @monitor = Opsicle::Monitor::App.new(@environment, options)
        @monitor.start
      end
    end

    def open_deploy(deployment_id)
      if deployment_id
        exec "open 'https://console.aws.amazon.com/opsworks/home?#/stack/#{client.config.opsworks_config[:stack_id]}/deployments'"
      else
        puts 'deploy failed'
      end
    end
  end
end
