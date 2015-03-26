require "spec_helper"
require "opsicle"

module Opsicle
  describe ListInstances do
    subject { ListInstances.new('derp') }

    context "#execute" do
      let(:client) { double }
      let(:layers) { [ { layer_id: 1, name: "Layer 1" }, { layer_id: 2, name: "Layer 2" }] }
      let(:instances) { [
          { hostname: 'test', layer_ids: [1], status: 'online', instance_id: 'opsworks-instance-id'},
          { hostname: 'test2', layer_ids: [2], status: 'online', instance_id: 'opsworks-instance-id2'},
        ] }
      before do
        allow(Client).to receive(:new).with('derp').and_return(client)
      end

      it "shows a table with all of the instances for the stack from OpsWorks" do
        expect(subject).to receive(:get_instances).and_return(instances)
        expect(subject).to receive(:print).with(instances)
        subject.execute
      end
    end

    context "#client" do
      it "generates a new aws client from the given configs" do
        expect(Client).to receive(:new).with('derp')
        subject.client
      end
    end

  end
end
