require 'opsicle/config'

module Opsicle
  class Client
    attr_reader :opsworks
    attr_reader :s3
    attr_reader :config

    def initialize(environment)
      @config = Config.instance
      @config.configure_aws!(environment)
      @opsworks = AWS::OpsWorks.new.client
      @s3 = AWS::S3.new
    end

    def run_command(command, command_args={}, options={})
      opts = command_options(command, command_args, options)
      Output.say_verbose "OpsWorks call: create_deployment(#{opts})"
      opsworks.create_deployment(opts)
    end

    def api_call(command, options={})
      opsworks.public_send(command, options)
    end

    def opsworks_url
      "https://console.aws.amazon.com/opsworks/home?#/stack/#{@config.opsworks_config[:stack_id]}"
    end

    def command_options(command, command_args={}, options={})
      config.opsworks_config.merge(options).merge({ command: { name: command, args: command_args } })
    end
    private :command_options

  end
end
