require "spec_helper"
require "opsicle"
require 'gli'
require "opsicle/user_profile"

module Opsicle
  describe CloneableInstance do
    before do
      @instance = double('instance1', :hostname => 'example-hostname-01', :status => 'active',
                                       :ami_id => 'ami_id', :instance_type => 'instance_type',
                                       :agent_version => 'agent_version', :stack_id => 1234567890,
                                       :layer_ids => [12345, 67890], :auto_scaling_type => 'auto_scaling_type',
                                       :os => 'os', :ssh_key_name => 'ssh_key_name',
                                       :availability_zone => 'availability_zone', :virtualization_type => 'virtualization_type',
                                       :subnet_id => 'subnet_id', :architecture => 'architecture',
                                       :root_device_type => 'root_device_type', :install_updates_on_boot => 'install_updates_on_boot',
                                       :ebs_optimized => 'ebs_optimized', :tenancy => 'tenancy')
      @layer = double('layer1', :name => 'layer-1', :layer_id => 12345, :instances => [@instance])
      @new_instance = double('new_instance', :instance_id => 1029384756)
      @opsworks = double('opsworks', :create_instance => @new_instance)
      @cli = double('cli', :ask => 2)
    end

    context "#make_new_hostname" do
      it "should make a unique incremented hostname" do
        instance = CloneableInstance.new(@instance, @layer, @opsworks, @cli)
        expect(instance).to receive(:increment_hostname).and_return('example-hostname-03')
        instance.make_new_hostname('example-hostname-01', ['example-hostname-01', 'example-hostname-02'])
      end
    end

    context "#increment_hostname" do
      it "should increment the hostname" do
        instance = CloneableInstance.new(@instance, @layer, @opsworks, @cli)
        expect(instance).to receive(:hostname_unique?).and_return('example-hostname-03')
        instance.increment_hostname('example-hostname-01', ['example-hostname-01', 'example-hostname-02'])
      end
    end

    context "#clone" do
      it "should grab instances and make new hostname" do
        instance = CloneableInstance.new(@instance, @layer, @opsworks, @cli)
        expect(@layer).to receive(:instances)
        expect(instance).to receive(:make_new_hostname).and_return('example-hostname-03')
        instance.clone({})
      end

      it "should get information from old instance" do
        instance = CloneableInstance.new(@instance, @layer, @opsworks, @cli)
        expect(instance).to receive(:agent_version)
        expect(instance).to receive(:ami_id)
        expect(instance).to receive(:instance_type)
        instance.clone({})
      end

      it "should create new instance" do
        instance = CloneableInstance.new(@instance, @layer, @opsworks, @cli)
        expect(instance).to receive(:create_new_instance)
        instance.clone({})
      end
    end

    context "#create_new_instance" do
      it "should create an instance" do
        instance = CloneableInstance.new(@instance, @layer, @opsworks, @cli)
        expect(@opsworks).to receive(:create_instance)
        instance.create_new_instance('hostname', 'type', 'ami', 'agent_version')
      end

      it "should take information from old instance" do
        instance = CloneableInstance.new(@instance, @layer, @opsworks, @cli)
        expect(instance).to receive(:stack_id)
        expect(instance).to receive(:layer_ids)
        expect(instance).to receive(:auto_scaling_type)
        expect(instance).to receive(:os)
        expect(instance).to receive(:ssh_key_name)
        expect(instance).to receive(:availability_zone)
        expect(instance).to receive(:virtualization_type)
        expect(instance).to receive(:subnet_id)
        instance.create_new_instance('hostname', 'type', 'ami', 'agent_version')
      end
    end
  end
end
