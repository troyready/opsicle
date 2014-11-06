module Opsicle
  class Instances

    attr_accessor :client
    class <<self
      attr_accessor :client
    end

    def initialize(client)
      @client = client
    end

    def data
      instances(reload: true)
    end

    def instances(options={})
      # Only call the API again if you need to
      @instances = nil if options[:reload]
      @instances ||= client.api_call('describe_instances',
                                       :stack_id => client.config.opsworks_config[:stack_id]
                                      )[:instances]
    end
    private :instances

    def self.find_by_ip(client, ips)
      instances = new(client).data.reject { |instance| (ips & [instance[:public_ip], instance[:elastic_ip], instance[:private_ip]]).compact.empty? } 
      instances.empty? ? nil : instances 
    end

    def self.find_by_eip(client)
      instances =  new(client).data.reject { |instance| instance[:elastic_ip] == nil }
      instances.empty? ? nil : instances 
    end

  end
end
