require "spec_helper"
require "opsicle"

module Opsicle
  describe Config do
    subject { Config.new('derp') }
    context "with a valid config" do
      before do
        allow(File).to receive(:exist?).with(File.expand_path '~/.fog').and_return(true)
        allow(File).to receive(:exist?).with('./.opsicle').and_return(true)
        allow(YAML).to receive(:load_file).with(File.expand_path '~/.fog').and_return({'derp' => { 'aws_access_key_id' => 'key', 'aws_secret_access_key' => 'secret'}})
        allow(YAML).to receive(:load_file).with('./.opsicle').and_return({'derp' => { 'app_id' => 'app', 'stack_id' => 'stack'}})
      end

      context "#aws_config" do
        it "should contain access_key_id" do
          expect(subject.aws_config).to have_key(:access_key_id)
        end

        it "should contain secret_access_key" do
          expect(subject.aws_config).to have_key(:secret_access_key)
        end
      end

      context "#opsworks_config" do
        it "should contain stack_id" do
          expect(subject.opsworks_config).to have_key(:stack_id)
        end

        it "should contain app_id" do
          expect(subject.opsworks_config).to have_key(:app_id)
        end
      end

      context "#configure_aws!" do
        it "should load the config into the AWS module" do
          expect(subject.aws_config).to include(access_key_id: 'key', secret_access_key: 'secret')
          subject.configure_aws!
        end
      end
    end

    context "with a valid MFA config" do
      before do
        allow(File).to receive(:exist?).with(File.expand_path '~/.fog').and_return(true)
        allow(File).to receive(:exist?).and_call_original
        mock_fog = { 'derp' => { 'aws_access_key_id' => 'key', 'aws_secret_access_key' => 'secret',
                     'mfa_serial_number' => 'tacos' }}
        allow(YAML).to receive(:load_file).with(File.expand_path '~/.fog').and_return(mock_fog)

        mock_sts = Class.new
        mock_session = Class.new
        mock_keys = {access_key_id: 'key', secret_access_key: 'secret'}
        mock_credentials = {session_token: 'cats'}.merge(mock_keys)
        allow(mock_session).to receive(:credentials).and_return(mock_credentials)
        allow(mock_sts).to receive(:new_session).and_return(mock_session)
        allow(Aws::STS::Client).to receive(:new).with(credentials: mock_keys, region: 'us-east-1').and_return(mock_sts)
        allow(Output).to receive(:ask).and_return(123456)
      end

      context "#configure_aws!" do
        it "should load the config into the AWS module" do
          expect(subject.aws_config).to include(access_key_id: 'key', secret_access_key: 'secret', session_token: 'cats')
          subject.configure_aws!
        end
      end
    end

    context "missing configs" do
      before do
        allow(File).to receive(:exist?).with(File.expand_path '~/.fog').and_return(false)
        allow(File).to receive(:exist?).with('./.opsicle').and_return(false)
      end

      context "#aws_config" do
        it "should gracefully raise an exception if no .fog file was found" do
          expect {subject.aws_config}.to raise_exception(Config::MissingConfig)
        end
      end

      context "#fog_config" do
        it "should gracefully raise an exception if no .fog file was found" do
          expect {subject.aws_config}.to raise_exception(Config::MissingConfig)
        end
      end

      context "#opsworks_config" do
        it "should gracefully raise an exception if no .fog file was found" do
          expect {subject.opsworks_config}.to raise_exception(Config::MissingConfig)
        end
      end
    end
  end
end
