module Opsicle
  class CloneableLayer
    attr_accessor :name, :layer_id, :instances, :opsworks, :cli

    def initialize(name, layer_id, opsworks, cli)
      self.name = name
      self.layer_id = layer_id
      self.opsworks = opsworks
      self.cli = cli
      self.instances = []
    end

    def get_cloneable_instances
      ops_instances = @opsworks.describe_instances({ :layer_id => layer_id }).instances
      ops_instances.each do |instance|
        self.instances << CloneableInstance.new(instance, self, @opsworks, @cli)
      end
      self.instances
    end
  end
end
