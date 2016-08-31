require "spec_helper"
require "opsicle"
require 'gli'
require "opsicle/user_profile"

module Opsicle
  describe CloneInstance do
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

      allow_any_instance_of(HighLine).to receive(:ask).with("Layer?\n", Integer).and_return(2)
      allow_any_instance_of(HighLine).to receive(:ask).with("Instances? (enter as a comma separated list)\n", String).and_return('2')
      allow_any_instance_of(HighLine).to receive(:ask).with("Do you wish to rewrite this hostname?\n1) Yes\n2) No", Integer).and_return(2)
      allow_any_instance_of(HighLine).to receive(:ask).with("Please write in the new instance's hostname and press ENTER:").and_return('example-hostname')
    end
    
    context "#execute" do
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

    context "#select_layer" do
      it "should list layers" do
        expect(@opsworks).to receive(:describe_layers)
        CloneInstance.new(:environment).select_layer
      end

      it "should get the layer id" do
        expect(@layer2).to receive(:layer_id)
        CloneInstance.new(:environment).select_layer
      end
    end

    context "#select_instances" do
      it "should list instances" do
        expect(@instances).to receive(:instances)
        CloneInstance.new(:environment).select_instances(@instances)
      end

      it "should get the hostnames and statuses" do
        expect(@instance1).to receive(:hostname)
        expect(@instance1).to receive(:status)
        expect(@instance2).to receive(:hostname)
        expect(@instance2).to receive(:status)
        CloneInstance.new(:environment).select_instances(@instances)
      end
    end

    context "#make_new_hostname" do
      it "should list instances" do
        clone = CloneInstance.new(:environment)
        expect(clone).to receive(:increment_hostname).and_return('example-hostname-03')
        clone.make_new_hostname('example-hostname-01', ['example-hostname-01', 'example-hostname-02'])
      end
    end

    context "#increment_hostname" do
      it "should increment the hostname" do
        clone = CloneInstance.new(:environment)
        expect(clone).to receive(:hostname_unique?).and_return(true)
        clone.increment_hostname('example-hostname-01', ['example-hostname-01', 'example-hostname-02'])
      end
    end

    context "#clone_instance" do
      it "should grab instances and make new hostname" do
        clone = CloneInstance.new(:environment)
        expect(@instances).to receive(:instances)
        expect(clone).to receive(:make_new_hostname).and_return('example-hostname-03')
        clone.clone_instance(@instances, ['example-hostname-01', 'example-hostname-02'], 1, {})
      end

      it "should get information from old instance" do
        clone = CloneInstance.new(:environment)
        expect(@instance2).to receive(:ami_id)
        expect(@instance2).to receive(:instance_type)
        expect(@instance2).to receive(:agent_version)
        clone.clone_instance(@instances, ['example-hostname-01', 'example-hostname-02'], 1, {})
      end

      it "should create new instance" do
        clone = CloneInstance.new(:environment)
        expect(clone).to receive(:create_new_instance).and_return(true)
        clone.clone_instance(@instances, ['example-hostname-01', 'example-hostname-02'], 1, {})
      end
    end

    context "#create_new_instance" do
      it "should create an instance" do
        clone = CloneInstance.new(:environment)
        expect(@opsworks).to receive(:create_instance).and_return(@new_instance)
        clone.create_new_instance(@instance2, 'instance_type', 'hostname', 'ami_id', 'agent_version')
      end

      it "should take information from old instance" do
        clone = CloneInstance.new(:environment)
        expect(@instance2).to receive(:stack_id)
        expect(@instance2).to receive(:layer_ids)
        expect(@instance2).to receive(:auto_scaling_type)
        expect(@instance2).to receive(:os)
        expect(@instance2).to receive(:ssh_key_name)
        expect(@instance2).to receive(:availability_zone)
        expect(@instance2).to receive(:virtualization_type)
        expect(@instance2).to receive(:subnet_id)
        clone.create_new_instance(@instance2, 'instance_type', 'hostname', 'ami_id', 'agent_version')
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
