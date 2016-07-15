require "spec_helper"
require "opsicle"

module Opsicle
  describe GetFailureLogHelper do
    subject { GetFailureLog.new('derp') }
    # let(:aws_client) { double }
    # let(:config) { double }
    # before do
    #   mock_keys = {access_key_id: 'key', secret_access_key: 'secret'}
    #   allow(config).to receive(:aws_credentials).and_return(mock_keys)
    #   allow(config).to receive(:opsworks_config).and_return({ stack_id: 'stack', app_id: 'app', something_else: 'true' })
    #   allow(Config).to receive(:new).and_return(config)
    #   allow(Config).to receive(:instance).and_return(config)
    #   allow(Aws::OpsWorks::Client).to receive(:new).and_return(aws_client)
    #   allow(Aws::S3::Client).to receive(:new).and_return(aws_client)
    #   allow(config).to receive(:configure_aws_environment!).with("derp")
    #   allow(aws_client).to receive(:configure_aws_environment!).with("derp")
    #   allow(subject).to receive(:configure_aws_environment!).with("derp")
    #   allow(Client).to receive(:configure_aws_environment!).with("derp")
    # end

    # context "#run_command" do
    #   it "calls out to the aws client with all the config options" do
    #     expect(aws_client).to receive(:create_deployment).with(
    #       hash_including(
    #         command: { name: 'deploy', args: {} },
    #         stack_id: 'stack',
    #         app_id: 'app'
    #       )
    #     )
    #     subject.run_command('deploy')
    #   end
    #   it "removes extra options from the opsworks config" do
    #     expect(aws_client).to receive(:create_deployment).with(hash_excluding(:something_else))
    #     subject.run_command('deploy')
    #   end
    # end
  end
end
