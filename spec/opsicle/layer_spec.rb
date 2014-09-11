require "spec_helper"
require "opsicle"

module Opsicle
  describe Layer do
    let(:client) { double }
    let(:config) { double }

    subject { Opsicle::Layer }
    context "#get_info" do
      let(:client) { double }
      let(:layer1) { subject.new(client, :id => 1, :name => "layer1")}
      let(:layer2) { subject.new(client, :id => 2, :name => "layer2")}
      let(:layers) { [ { shortname: "layer1", layer_id: 1, name: "Layer 1" }, { shortname: "layer2", layer_id: 2, name: "Layer 2" }] }
      
      before do
        allow(subject).to receive(:get_layers).and_return(layers)
      end

      it "returns an array of layer_ids from the input layer (singular)" do
        expect(subject.send(:get_info)[0]).to be_an_instance_of Opsicle::Layer
        expect(subject.send(:get_info)[1]).to be_an_instance_of Opsicle::Layer
      end

    end

    context "#get_instance_ids" do
      let(:response) {{ :instances => [{:stack_id => "aaa", :instance_id => "111"},{:stack_id => "bbb", :instance_id => "222"}]}}
      before do
        allow(client).to receive(:api_call).with('describe_instances',layer_id: "opsworkslayer").and_return(response)
      end

      it "returns an array of instance_ids from the input layer_id" do
        expect(subject.new(client, id: "opsworkslayer").get_instance_ids).to eq(["111","222"])
      end
    end

    context "#instance_ids" do
      let(:layer1) { double }
      let(:layer2) { double }
      before do
        allow(layer1).to receive(:name).and_return("aaa")
        allow(layer2).to receive(:name).and_return("bbb")
        allow(layer1).to receive(:get_instance_ids).and_return(["111","222"])
        allow(layer2).to receive(:get_instance_ids).and_return(["333","444"])
        allow(subject).to receive(:get_info).and_return([layer1,layer2])
      end

      it "returns the instance ids from layer_names" do
        expect(subject.instance_ids(client, ["aaa","bbb"])).to eq(["111","222","333","444"])
      end

      it "returns the instance ids from layer_names, filters out doubles" do
        allow(layer2).to receive(:get_instance_ids).and_return(["222","333"])
        expect(subject.instance_ids(client, ["aaa","bbb"])).to eq(["111","222","333"])
      end
    end
  end
end
