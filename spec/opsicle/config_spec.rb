require "spec_helper"
require "opsicle"

module Opsicle
  describe Config do
    subject { Config.new }
    context "with a valid config" do
      before do
        allow(File).to receive(:exist?).with(File.expand_path '~/.fog').and_return(true)
        allow(File).to receive(:exist?).with('./.opsicle').and_return(true)
        allow(YAML).to receive(:load_file).with(File.expand_path '~/.fog').and_return({'derp' => { 'aws_access_key_id' => 'key', 'aws_secret_access_key' => 'secret'}})
        allow(YAML).to receive(:load_file).with('./.opsicle').and_return({'derp' => { 'app_id' => 'app', 'stack_id' => 'stack'}})
      end
      before :each do
        subject.configure_aws_environment!('derp')
      end

      context "#aws_config" do
        it "should contain access_key_id" do
          expect(subject.aws_config).to have_key(:access_key_id)
          expect(subject.aws_config).to eq({ :access_key_id => 'key', :secret_access_key => 'secret'})
        end

        it "should contain secret_access_key" do
          expect(subject.aws_config).to have_key(:secret_access_key)
          expect(subject.aws_config).to eq({ :access_key_id => 'key', :secret_access_key => 'secret'})
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

      context "#aws_credentials" do
        it "should return aws credentials" do
          credentials = double
          allow(Aws::Credentials).to receive(:new).and_return(credentials)
          expect(subject.aws_credentials).to eq(credentials)
        end
      end

      context "#configure_aws_environment!" do
        it "should return the environment as a symbol" do
          expect(subject.configure_aws_environment!("environment")).to eq(:environment)
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

    context "singleton support" do
      it "should return a single instance" do
        expect(Config.instance).to eq(Config.instance)
      end
    end
  end
end
