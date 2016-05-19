require "spec_helper"
require "opsicle"

module Opsicle
  describe UserProfileInfo do
    subject { UserProfileInfo.new(env) }

    let(:env) { "example" }
    let(:client) { double("Client") }
    let(:user_profile) { double("UserProfile", attributes: {foo: "bar"}) }

    before do
      allow(Client).to receive(:new).with(env).and_return(client)
      allow(UserProfile).to receive(:new).with(client).and_return(user_profile)
    end

    context "#execute" do
      it "renders its output as JSON" do
        allow(subject).to receive(:output).and_return(user_profile.attributes)

        expect(Output).to receive(:say).with(user_profile.attributes.to_json)

        subject.execute
      end
    end

    context "#output" do
      it "returns the profile's attributes" do
        expect(subject.output).to eq(user_profile.attributes)
      end
    end
  end
end
