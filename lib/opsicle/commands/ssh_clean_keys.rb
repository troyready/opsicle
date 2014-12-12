module Opsicle
  class SSHCleanKeys
    attr_reader :client

    def initialize(environment)
      @client = Client.new(environment)
    end

    def execute(options={})
      instances.each do |instance|
        # Fun note: public_dns will be for the elastic ip (if elastic_ip?)
        host_keys = [:elastic_ip, :public_ip, :public_dns]
        hosts = host_keys.map { |key| instance[key] }
        hosts = hosts.reject { |i| i.nil? }
        hosts.uniq.each do |host|
          # Is this properly escaped against expansion?
          command = "ssh-keygen -R #{host}"
          Output.say_verbose "Executing: #{command}"
          system(command)
        end
      end
    end

    def instances
      client.api_call(:describe_instances, { stack_id: client.config.opsworks_config[:stack_id] })
        .data[:instances]
    end
  end
end
