require "spec_helper"
require "opsicle"

module Opsicle
  describe FailureLog do
    before do
      instance = double('instance', instance_id: 123456)
      instances = double('instances', instances: [instance])
      deploy1 = double('deploy', status: "fail", deployment_id: '678903', instance_ids: [123456])
      deploy2 = double('deploy', status: "fail", deployment_id: '294172', instance_ids: [123456])
      deployments = double('deployments', deployments: [deploy1, deploy2])
      command1 = double('command', log_url: 'http://example1.com', deployment_id: '678903')
      command2 = double('command', log_url: 'http://example2.com', deployment_id: '294172')
      commands = {:commands => [command1, command2]}
      @stack = double('stack', stack_id: '12345')
      opsworks_client = double('opsworks_client', describe_deployments: deployments, describe_instances: instances,describe_commands: commands)
      @client = double('client', opsworks: opsworks_client)
      allow(Client).to receive(:new).and_return(@client)
      allow(Opsicle::Stack).to receive(:new).and_return(@stack)

    end

    it "should initialize a new FailureLog" do
      expect(Client).to receive(:new)
      expect(Opsicle::Stack).to receive(:new)
      FailureLog.new('environment')
    end

    it "should get a recent failure log" do
      log = FailureLog.new('environment')
      expect(@client).to receive(:opsworks)
      expect(log).to receive(:system).and_return(true)
      log.execute
    end
  end
end
