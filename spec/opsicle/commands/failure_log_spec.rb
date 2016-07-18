require "spec_helper"
require "opsicle"

module Opsicle
  describe FailureLog do
    before do
      @instance = double('instance', instance_id: 123456)
      @instances = double('instances', instances: [@instance])
      @deploy1 = double('deploy', status: "fail", deployment_id: 678903, instance_ids: [123456])
      @deploy2 = double('deploy', status: "fail", deployment_id: 294172, instance_ids: [123456])
      @deployments = double('deployments', deployments: [@deploy1, @deploy2])
      @command1 = double('command', log_url: 'http://example1.com', deployment_id: 678903)
      @command2 = double('command', log_url: 'http://example2.com', deployment_id: 294172)
      @commands = {:commands => [@command1, @command2]}
      @stack = double('stack', stack_id: '12345')
      @opsworks_client = double('opsworks_client', describe_deployments: @deployments, describe_instances: @instances, describe_commands: @commands)
      @client = double('client', opsworks: @opsworks_client)
      allow(Client).to receive(:new).and_return(@client)
      allow(Opsicle::Stack).to receive(:new).and_return(@stack)
      @log = FailureLog.new('environment')
      allow(@log).to receive(:system).and_return(true)
    end

    context '#fetch' do
      it "should initialize a new FailureLog" do
        expect(Client).to receive(:new)
        expect(Opsicle::Stack).to receive(:new)
        FailureLog.new('environment')
      end

      it "should get the deployment id of the first failed deploy" do
        expect(@deploy1).to receive(:deployment_id)
        @log.fetch
      end

      it "should get the instance ids of the first failed deploy" do
        expect(@deploy1).to receive(:instance_ids)
        @log.fetch
      end

      it "should get the log_url of the first target command" do
        expect(@command1).to receive(:log_url)
        @log.fetch
      end

      it "should open a recent failure log" do
        expect(@log).to receive(:system).and_return(true)
        @log.fetch
      end
    end

    context '#fetch_failed_deployments' do
      it "should grab deployments from opsworks" do
        expect(@opsworks_client).to receive(:describe_deployments)
        @log.fetch_failed_deployments
      end

      it "should grab deployments from opsworks's deployments" do
        expect(@deployments).to receive(:deployments)
        @log.fetch_failed_deployments
      end

      it "should question the status of each deployment" do
        expect(@deploy1).to receive(:status)
        expect(@deploy2).to receive(:status)
        @log.fetch_failed_deployments
      end
    end

    context '#fetch_instance_id' do
      it "should grab instances from opsworks" do
        expect(@opsworks_client).to receive(:describe_instances)
        @log.fetch_instance_id([123456])
      end

      it "should grab instances from opsworks's instances" do
        expect(@instances).to receive(:instances)
        @log.fetch_instance_id([123456])
      end

      it "should get the instance_id of the selected instance" do
        expect(@instance).to receive(:instance_id)
        @log.fetch_instance_id([123456])
      end
    end

    context '#fetch_target_command' do
      it "should grab commands from opsworks" do
        expect(@opsworks_client).to receive(:describe_commands)
        @log.fetch_target_command(123456, 678903)
      end

      it "should get the deployment id of each command" do
        expect(@command1).to receive(:deployment_id)
        expect(@command2).to receive(:deployment_id)
        @log.fetch_target_command(123456, 678903)
      end
    end
  end
end
