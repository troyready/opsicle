require "spec_helper"
require "opsicle"

module Opsicle
  describe Client do
    subject { Client.new('derp') }
    let(:aws_client) { double }
    let(:config) { double }
    before do
      ow_stub = double
      allow(config).to receive(:opsworks_config).and_return({ stack_id: 'stack', app_id: 'app', something_else: 'true' })
      allow(ow_stub).to receive(:client).and_return(aws_client)
      allow(Config).to receive(:new).and_return(config)
      allow(AWS::OpsWorks).to receive(:new).and_return(ow_stub)
    end

    context "#run_command" do
      it "calls out to the aws client with all the config options" do
        expect(config).to receive(:configure_aws!)
        expect(aws_client).to receive(:create_deployment).with(
          hash_including(
            command: { name: 'deploy', args: {} },
            stack_id: 'stack',
            app_id: 'app'
          )
        )
        subject.run_command('deploy')
      end
      it "removes extra options from the opsworks config" do
        expect(config).to receive(:configure_aws!)
        expect(aws_client).to receive(:create_deployment).with(hash_excluding(:something_else))
        subject.run_command('deploy')
      end
    end
  end
end
