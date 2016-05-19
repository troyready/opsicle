require "spec_helper"
require "opsicle/user_profile"

module Opsicle
  describe UserProfile do
    subject { UserProfile.new client }

    let(:client) { double("Opsicle::Client") }

    let(:ssh_username) { double }
    let(:iam_username) { double }
    let(:public_key) { double }
    let(:arn) { double }

    before do
      allow(client).to receive(:api_call).with(:describe_my_user_profile).and_return({
        user_profile: {
          iam_user_arn: arn,
          name: iam_username,
          ssh_username: ssh_username,
          ssh_public_key: public_key,
        }
      })
    end

    context "#ssh_username" do
      it "returns the IAM profile's SSH username" do
        expect(subject.ssh_username).to eq(ssh_username)
      end
    end

    context "#iam_username" do
      it "returns the IAM profile's AWS username" do
        expect(subject.iam_username).to eq(iam_username)
      end
    end

    context "#public_key" do
      it "returns the IAM profile's SSH public key" do
        expect(subject.public_key).to eq(public_key)
      end
    end

    context "#arn" do
      it "returns the IAM profile's ARN ID" do
        expect(subject.arn).to eq(arn)
      end
    end
  end
end
