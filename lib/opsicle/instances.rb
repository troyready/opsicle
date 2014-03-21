module Opsicle
  class Instances

    def initialize(client)
      @client = client
    end

    def data
      instances(reload: true)
    end

    def instances(options={})
      # Only call the API again if you need to
      @instances = nil if options[:reload]
      @instances ||= @client.api_call('describe_instances',
                                       :stack_id => @client.config.opsworks_config[:stack_id]
                                      )[:instances]
    end
    private :instances

  end
end
