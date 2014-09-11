module Opsicle
  class Layer

    attr_accessor :id, :name, :client
    class <<self
      attr_accessor :client
    end

    def initialize(client, options = {})
      @client = client
      @id = options[:id]
      @name = options[:name]
    end

    # Public - Gets all the instance ids for a  layer
    #
    # Return - An array of instance ids
    def get_instance_ids
      client.api_call('describe_instances', layer_id: id)[:instances].map{ |s| s[:instance_id] }
    end

    # Private - Gets layer info from OpsWorks
    #
    # Return - An array of layer objects
    def self.get_info
      get_layers.map do |layer|
        new(client, id: layer[:layer_id], name: layer[:shortname])
      end
    end
    private_class_method :get_info

    def self.get_layers
      client.api_call('describe_layers', stack_id: client.config.opsworks_config[:stack_id])[:layers]
    end
    # Public - gets all the layer ids for the given layers
    #
    # client - a new Client
    # layers - an array of layer shortnames
    #
    # Return - An array of instance ids belonging to the input layers
    def self.instance_ids(client, layers)
      @client = client
      get_info.map{ |layer| layer.get_instance_ids if layers.include?(layer.name) }.flatten.compact.uniq
    end

  end
end

