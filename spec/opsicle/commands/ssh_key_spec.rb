require "spec_helper"
require "opsicle"

module Opsicle
  describe SSHKey do
    let(:valid_key) { "my-valid-public-key" }
    subject { SSHKey.new("derp", valid_key) }
    let(:client) { double(config: double(opsworks_config: {stack_id: "1234"})) }
    let(:api_call) { double }

    before do
      allow(Client).to receive(:new).with("derp").and_return(client)
    end

    context "#execute" do
      context "valid ssh key" do
        it "confirms that the given file is a public ssh key" do
          expect(subject).to receive(:validate!)
          expect(Output).to receive(:say).with(/success/)
          allow(subject).to receive(:update)
          subject.execute
        end

        it "updates the user's ssh-key on opsworks" do
          allow(subject).to receive(:validate!)
          expect(Output).to receive(:say).with(/success/)
          expect(subject).to receive(:update)
          subject.execute
        end
      end
    end

    context "#validate!" do
      it "validates a valid ssh key" do
        allow(File).to receive(:exists?).and_return(true)
        allow(subject).to receive(:valid_key_file?).and_return(true)
        allow(subject).to receive(:public_key?).and_return(true)

        expect { subject.validate! }.to_not raise_error
      end

      it "raises an error for a private ssh key" do
        allow(File).to receive(:exists?).and_return(true)
        allow(subject).to receive(:valid_key_file?).and_return(true)
        allow(subject).to receive(:public_key?).and_return(false)

        expect { subject.validate! }.to raise_error
      end

      it "raises an error for a non-key file" do
        allow(File).to receive(:exists?).and_return(true)
        allow(subject).to receive(:valid_key_file?).and_return(false)
        allow(subject).to receive(:public_key?).and_return(true)

        expect { subject.validate! }.to raise_error(InvalidKeyFile)
      end

      it "raises an error if no key file exists" do
        allow(File).to receive(:exists?).and_return(false)
        allow(subject).to receive(:valid_key_file?).and_return(true)
        allow(subject).to receive(:public_key?).and_return(true)

        expect { subject.validate! }.to raise_error(KeyFileNotFound)
      end
    end

    context "#update" do
      it "updates the users ssh key via the aws api" do
        allow(subject).to receive(:key).and_return(valid_key)
        expect(client).to receive(:api_call).with(:update_my_user_profile, {ssh_public_key: valid_key }).and_return(api_call)
        subject.update
      end
    end
  end
end
