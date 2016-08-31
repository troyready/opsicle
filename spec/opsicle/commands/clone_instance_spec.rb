require "spec_helper"
require "opsicle"
require 'gli'
require "opsicle/user_profile"

module Opsicle
  describe CloneInstance do
    context "#execute" do
      before do
        @instance1 = double('instance1', :hostname => 'example-hostname-01', :status => 'active',
                                         :ami_id => 'ami_id', :instance_type => 'instance_type',
                                         :agent_version => 'agent_version', :stack_id => 1234567890,
                                         :layer_ids => [12345, 67890], :auto_scaling_type => 'auto_scaling_type',
                                         :os => 'os', :ssh_key_name => 'ssh_key_name',
                                         :availability_zone => 'availability_zone', :virtualization_type => 'virtualization_type',
                                         :subnet_id => 'subnet_id', :architecture => 'architecture',
                                         :root_device_type => 'root_device_type', :install_updates_on_boot => 'install_updates_on_boot',
                                         :ebs_optimized => 'ebs_optimized', :tenancy => 'tenancy')
        @instance2 = double('instance2', :hostname => 'example-hostname-02', :status => 'active',
                                         :ami_id => 'ami_id', :instance_type => 'instance_type',
                                         :agent_version => 'agent_version', :stack_id => 1234567890,
                                         :layer_ids => [12345, 67890], :auto_scaling_type => 'auto_scaling_type',
                                         :os => 'os', :ssh_key_name => 'ssh_key_name',
                                         :availability_zone => 'availability_zone', :virtualization_type => 'virtualization_type',
                                         :subnet_id => 'subnet_id', :architecture => 'architecture',
                                         :root_device_type => 'root_device_type', :install_updates_on_boot => 'install_updates_on_boot',
                                         :ebs_optimized => 'ebs_optimized', :tenancy => 'tenancy')
        @instances = double('instances', :instances => [@instance1, @instance2])
        
        @layer1 = double('layer1', :name => 'layer-1', :layer_id => 12345)
        @layer2 = double('layer2', :name => 'layer-2', :layer_id => 67890)
        @layers = double('layers', :layers => [@layer1, @layer2])
        
        @new_instance = double('new_instance', :instance_id => 1029384756)
        
        @opsworks = double('opsworks', :describe_instances => @instances,
                                       :describe_layers => @layers,
                                       :create_instance => @new_instance)
        @config = double('config', :opsworks_config => {:stack_id => 1234567890})
        @client = double('client', :config => @config,
                                   :opsworks => @opsworks)
        
        allow(Client).to receive(:new).with(:environment).and_return(@client)
        # allow(Highline).to receive(:new)
      end

      it "creates a new instance" do
        expect(@opsworks).to receive(:create_instance)
        CloneInstance.new(:environment).execute
      end

      it "lists all current layers" do
        expect(@opsworks).to receive(:describe_layers)
        CloneInstance.new(:environment).execute
      end

      it "lists all current instances" do
        expect(@opsworks).to receive(:describe_instances)
        CloneInstance.new(:environment).execute
      end
    end

    context "#client" do
      it "generates a new AWS client from the given configs" do
        @config = double('config', :opsworks_config => {:stack_id => 1234567890})
        @client = double('client', :config => @config,
                                   :opsworks => @opsworks)
        expect(Client).to receive(:new).with(:environment).and_return(@client)
        CloneInstance.new(:environment)
      end
    end
  end
end
