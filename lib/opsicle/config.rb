require 'yaml'
require 'aws-sdk'

module Opsicle
  class Config
    FOG_CONFIG_PATH = '~/.fog'
    OPSICLE_CONFIG_PATH = './.opsicle'
    SESSION_DURATION = 3600

    attr_reader :environment

    def initialize(environment)
      @environment = environment.to_sym
    end

    def aws_credentials
      Aws::Credentials.new(aws_config[:access_key_id], aws_config[:secret_access_key])
    end

    def aws_config
      return @aws_config if @aws_config
      if fog_config[:mfa_serial_number]
        creds = get_session.credentials
        @aws_config = { access_key_id: creds.access_key_id, secret_access_key: creds.secret_access_key }
      else
        @aws_config = { access_key_id: fog_config[:aws_access_key_id], secret_access_key: fog_config[:aws_secret_access_key] }
      end
    end

    def fog_config
      return @fog_config if @fog_config
      @fog_config = load_config(File.expand_path(FOG_CONFIG_PATH))
    end

    def opsworks_config
      @opsworks_config ||= load_config(OPSICLE_CONFIG_PATH)
    end
    
    def configure_aws!(environment)
      return if environment == @environment
      @environment = environment.to_sym
      end

    def load_config(file)
      raise MissingConfig, "Missing configuration file: #{file}  Run 'opsicle help'" unless File.exist?(file)
      env_config = symbolize_keys(YAML.load_file(file))[environment] rescue {}
      raise MissingEnvironment, "Configuration for the \'#{environment}\' environment could not be found in #{file}" unless env_config != nil

      env_config
    end

    def get_mfa_token
      return @token if @token
      @token = Output.ask("Enter MFA token: "){ |q|  q.validate = /^\d{6}$/ }
    end

    def get_session
      return @session if @session
      # credentials = {access_key_id: fog_config[:aws_access_key_id],
      #                secret_access_key: fog_config[:aws_secret_access_key]}
      sts = Aws::STS::Client.new(access_key_id: fog_config[:aws_access_key_id],
                                 secret_access_key: fog_config[:aws_secret_access_key],
                                 region: 'us-east-1')
      role_arn = fog_config[:mfa_serial_number]
      role_arn = role_arn.scan(/(arn:aws:iam::[\d]+:)/).flatten.first
      role_arn << "role/"
      @session = sts.assume_role(role_arn: role_arn,
                                 role_session_name: "RoleSession1",
                                 duration_seconds: session_duration,
                                 serial_number: fog_config[:mfa_serial_number],
                                 token_code: get_mfa_token)
      # @session = nil
    end

    def session_duration
      fog_config = load_config(File.expand_path(FOG_CONFIG_PATH))
      fog_config[:session_duration] || SESSION_DURATION
    end

    # We want all ouf our YAML loaded keys to be symbols
    # taken from http://devblog.avdi.org/2009/07/14/recursively-symbolize-keys/
    def symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end

    MissingConfig = Class.new(StandardError)
    MissingEnvironment = Class.new(StandardError)

  end
end
