module Opsicle
  module DeployHelper
    def launch_stack_monitor(response, options={})
      # Monitoring preferences
      if options[:browser]
        open_deploy(response[:deployment_id])
      elsif options[:monitor] # Default option
        Output.say_verbose "Starting Stack Monitor..."
        @monitor = Opsicle::Monitor::App.new(@environment, parse_options(response, options))
        @monitor.start
      end
    end

    def open_deploy(deployment_id)
      if deployment_id
        command = "open 'https://console.aws.amazon.com/opsworks/home?#/stack/#{client.config.opsworks_config[:stack_id]}/deployments'"
        Output.say_verbose "Executing shell command: #{command}"
        %x(#{command})
      else
        Output.say "Deploy failed. No deployment_id was received from OpsWorks", :error
      end
    end

    private

    def parse_options(response, options)
      if options[:track]
        options.delete(:track)
        options[:deployment_id] = response[:deployment_id]
      end

      options
    end
  end
end
