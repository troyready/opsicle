require 'gli'
require "opsicle/user_profile"

module Opsicle
  class CloneInstance

    def initialize(environment)
      @client = Client.new(environment)
      @stack_id = @client.config.opsworks_config[:stack_id]
      @opsworks = @client.opsworks
      @cli = HighLine.new
    end

    def execute(options={})
      puts "Stack ID = #{@stack_id}"
      puts "\nLayers:\n"
      layers = @opsworks.describe_layers({ :stack_id => @stack_id }).data
      layers[:layers].each_with_index {|layer, index| puts "#{index.to_i + 1} #{layer.name}"}
      layer_index = @cli.ask("Layer?\n", Integer) { |q| q.in = 1..layers[:layers].length.to_i } - 1

      layer_name = layers.layers[layer_index].name
      layer_id = layers.layers[layer_index].layer_id

      puts "\nInstances:\n"
      instances = @opsworks.describe_instances({:layer_id => layer_id}).data
      instances[:instances].each_with_index {|instance, index| puts "#{index.to_i + 1} #{instance.status} #{instance.hostname}" }
      instance_indexes_list = @cli.ask("Instances? (comma sep list)\n", lambda { |str| str.split(/,\s*/) })
      instance_indexes_list.map! { |instance_index| instance_index.to_i - 1 }

      hostname_modifier = @cli.ask("\nHostname modifier? (number from 1 to 90\n", Integer) { |q| q.in = 1..90 }

      instance_indexes_list.each do |instance_index|
        old_instance = instances.instances[instance_index]
        # Overrides
        new_instance_hostname = instances.instances[instance_index].hostname.gsub(/(\d\d\z)/) { "#{($1.to_i + hostname_modifier).to_s.rjust(2, '0')}"}
        options[:ami]? new_instance_ami_id = options[:ami] : new_instance_ami_id = old_instance.ami_id
        options[:instance_type]? instance_type = options[:instance_type] : instance_type = old_instance.instance_type 
        puts "\nGenerated hostname = #{new_instance_hostname}\n"

        new_instance = @opsworks.create_instance({
          stack_id: old_instance.stack_id, # required
          layer_ids: old_instance.layer_ids, # required
          instance_type: instance_type, # required
          auto_scaling_type: old_instance.auto_scaling_type, # accepts load, timer
          hostname: new_instance_hostname,
          os: old_instance.os,
          ami_id: new_instance_ami_id,
          ssh_key_name: old_instance.ssh_key_name,
          availability_zone: old_instance.availability_zone,
          virtualization_type: old_instance.virtualization_type,
          subnet_id: old_instance.subnet_id,
          architecture: old_instance.architecture, # accepts x86_64, i386
          root_device_type: old_instance.root_device_type, # accepts ebs, instance-store
          install_updates_on_boot: old_instance.install_updates_on_boot,
          #ebs_optimized: old_instance.ebs_optimized,
          agent_version: old_instance.agent_version,
          tenancy: old_instance.tenancy,
        })
        puts "New instance is created: #{new_instance.instance_id}"
      end

    end
  end
end
