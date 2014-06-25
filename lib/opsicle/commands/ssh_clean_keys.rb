module Opsicle
  class SSHCleanKeys
    attr_reader :client

    def initialize(environment)
      @client = Client.new(environment)
    end

    def execute(options={})
      instances.each do |instance|
        # As a side note, maybe always connecting to the instance ip
        # (NOT the elastic ip) would bypass this issue

        # Need a way to lookup the elastic publid dns name of the elastic ip
        ip_keys = [:elastic_ip, :public_dns, :public_ip,
                  :private_dns, :private_ip]
        ips = ip_keys.map{ |key| instance[key] }
        ips = ips.reject{ |i| i.nil? }
        #ips = ips.find_all{ |i| i }

        ips.each do |ip|
          # Is this properly escaped against expansion?
          command = "ssh-keygen -R #{ip}"
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
