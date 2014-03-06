require "spec_helper"
require "opsicle"

module Opsicle
  describe List do
    subject { List.new('derp') }

    context "#execute" do
      let(:client) { double }
      let(:stack_ids) { [1,2,3] }
      let(:apps) { [{ name: 'test', stack_id: 1, app_id: 1}, { name: 'test2', stack_id: 2, app_id: 2}, { name: 'test3', stack_id: 3, app_id: 3 }] }
      before do
        allow(Client).to receive(:new).with('derp').and_return(client)
      end

      it "shows a table with all of the apps/stacks from OpsWorks" do
        expect(subject).to receive(:get_stacks).and_return(stack_ids)
        expect(subject).to receive(:get_apps).with(stack_ids).and_return(apps)
        expect(subject).to receive(:print).with(apps)
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
