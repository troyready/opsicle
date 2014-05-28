require 'terminal-table'

module Opsicle
  class ListInstances
    attr_reader :client, :layers

    def initialize(environment)
      @client = Client.new(environment)
    end

    def execute(options={})
      get_layers
      print(get_instances)
    end

    def get_layers
      @layers = client.api_call('describe_layers', stack_id: @client.config.opsworks_config[:stack_id])[:layers]
    end

    def get_instances
      Opsicle::Instances.new(client).data
    end

    def print(instances)
      puts Terminal::Table.new headings: ['Hostname', 'Layers', 'Status', 'Instance ID'], rows: instance_data(instances)
    end

    def instance_data(instances)
      instances.map{|instance| [instance[:hostname], layer_names(instance), instance[:status], instance[:instance_id]] }
    end

    def layer_names(instance)
      instance[:layer_ids].map{ |layer_id| layer_name(layer_id) }.join(" | ")
    end

    def layer_name(layer_id)
      layers.detect{ |layer| layer[:layer_id] == layer_id }[:name]
    end

  end
end
