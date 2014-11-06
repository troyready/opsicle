require "spec_helper"
require "opsicle"

module Opsicle
  describe Instances do
    let(:client) { double }
    let(:config) { double }

    let(:instance1) { {private_ip: "10.0.0.1", elastic_ip: "100.0.0.1", public_ip: "200.0.0.1"} }
    let(:instance2) { {private_ip: "10.0.0.2", elastic_ip: "100.0.0.2", public_ip: "200.0.0.2"} }

    subject {Opsicle::Instances}
    before do
      allow_any_instance_of(subject).to receive(:data).and_return([instance1,instance2])
    end

    context ".find_by_ip" do
      it "returns nil if no instances have a given ip" do
        expect(subject.find_by_ip(client, ["10.0.0.4","100.0.0.4"])).to eq(nil)
      end

      it "returns an instance if an instance has a given private_ip" do
        expect(subject.find_by_ip(client, ["10.0.0.1","100.0.0.4"])).to eq([instance1])
      end

      it "returns an instance if an instance has a given public_ip" do
        expect(subject.find_by_ip(client, ["100.0.0.2","100.0.0.4"])).to eq([instance2])
      end

      it "returns multiple instances with a given set of ips" do
        expect(subject.find_by_ip(client, ["100.0.0.2","200.0.0.1"])).to eq([instance1,instance2])
      end
    end

    context ".find_by_eip" do
      it "returns instances with an elastic_ip" do
        expect(subject.find_by_eip(client)).to eq([instance1,instance2])
      end

      context "one instance has an elastic_ip" do
        let(:instance2) { {private_ip: "10.0.0.2", public_ip: "200.0.0.2"} }
        it "returns instances with an elastic_ip" do
          expect(subject.find_by_eip(client)).to eq([instance1])
        end
      end

      context "no instances have an elastic_ip" do
        let(:instance1) { {private_ip: "10.0.0.1", public_ip: "200.0.0.1"} }
        let(:instance2) { {private_ip: "10.0.0.2", public_ip: "200.0.0.2"} }

        it "returns nil if no instances have a given ip" do
          expect(subject.find_by_eip(client)).to eq(nil)
        end

      end
    end

  end
end
