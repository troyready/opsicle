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
      layer_id = select_layer
      all_instances = @opsworks.describe_instances({:layer_id => layer_id}).data
      all_hostnames = all_instances[:instances].collect { |instance| instance.hostname }
      instance_indices_list = select_instances(layer_id)

      instance_indices_list.each do |instance_index|
        clone_instance(all_instances, all_hostnames, instance_index, options)
      end
    end

    def select_layer
      puts "\nLayers:\n"
      layers = @opsworks.describe_layers({ :stack_id => @stack_id }).data
      layers[:layers].each_with_index {|layer, index| puts "#{index.to_i + 1}) #{layer.name}"}
      layer_index = @cli.ask("Layer?\n", Integer) { |q| q.in = 1..layers[:layers].length.to_i } - 1
      layers.layers[layer_index].layer_id
    end

    def select_instances(layer_id)
      puts "\nInstances:\n"
      instances = @opsworks.describe_instances({ :layer_id => layer_id }).data
      instances[:instances].each_with_index {|instance, index| puts "#{index.to_i + 1}) #{instance.status} - #{instance.hostname}" }
      instance_indices_list = @cli.ask("Instances? (enter as a comma separated list)\n", lambda { |str| str.split(/,\s*/) })
      instance_indices_list.map! { |instance_index| instance_index.to_i - 1 }
    end

    def clone_instance(all_instances, all_hostnames, instance_index, options)
      old_instance = all_instances.instances[instance_index]
      new_instance_hostname = make_new_hostname(old_instance.hostname, all_hostnames)
      puts "\nWe will make a new instance with hostname: #{new_instance_hostname}"

      options[:ami] ? ami_id = options[:ami] : ami_id = old_instance.ami_id
      options[:instance_type] ? instance_type = options[:instance_type] : instance_type = old_instance.instance_type
      options[:agent_version] ? agent_version = options[:agent_version] : agent_version = old_instance.agent_version

      create_new_instance(old_instance, instance_type, new_instance_hostname, ami_id, agent_version)
    end

    def make_new_hostname(old_hostname, all_hostnames)
      if old_hostname =~ /\d/
        new_instance_hostname = increment_hostname(old_hostname, all_hostnames)
      else
        new_instance_hostname = old_hostname << "_clone"
      end
        
      puts "\nAutomatically generated hostname: #{new_instance_hostname}\n"
      rewriting = @cli.ask("Do you wish to rewrite this hostname?\n1) Yes\n2) No", Integer)
      
      if rewriting == 1
        new_instance_hostname = @cli.ask("Please write in the new instance's hostname and press ENTER:")
      end

      new_instance_hostname
    end

    def increment_hostname(hostname, all_hostnames)
      until hostname_is_unique(hostname, all_hostnames) do
        hostname = hostname.gsub(/(\d\d\z)/) { "#{($1.to_i + 1).to_s.rjust(2, '0')}"}
      end
      hostname
    end

    def hostname_is_unique(hostname, all_hostnames)
      !all_hostnames.include?(hostname)
    end

    def create_new_instance(old_instance, instance_type, new_instance_hostname, ami_id, agent_version)
      new_instance = @opsworks.create_instance({
        stack_id: old_instance.stack_id, # required
        layer_ids: old_instance.layer_ids, # required
        instance_type: instance_type, # required
        auto_scaling_type: old_instance.auto_scaling_type, # accepts load, timer
        hostname: new_instance_hostname,
        os: old_instance.os,
        ami_id: ami_id,
        ssh_key_name: old_instance.ssh_key_name,
        availability_zone: old_instance.availability_zone,
        virtualization_type: old_instance.virtualization_type,
        subnet_id: old_instance.subnet_id,
        architecture: old_instance.architecture, # accepts x86_64, i386
        root_device_type: old_instance.root_device_type, # accepts ebs, instance-store
        install_updates_on_boot: old_instance.install_updates_on_boot,
        #ebs_optimized: old_instance.ebs_optimized,
        agent_version: agent_version,
        tenancy: old_instance.tenancy,
      })
      puts "New instance is created: #{new_instance.instance_id}"
    end
  end
end
