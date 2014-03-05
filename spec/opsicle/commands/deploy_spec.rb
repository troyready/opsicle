require "spec_helper"
require "opsicle/commands/deploy"
require "opsicle/monitor"

module Opsicle
  describe Deploy do
    subject { Deploy.new('derp') }

    context "#execute" do
      let(:client) { double }
      let(:monitor) { double(:start => nil) }
      before do
        allow(Client).to receive(:new).with('derp').and_return(client)
        allow(client).to receive(:run_command).with('deploy').and_return({deployment_id: 'derp'})

        allow(Monitor::App).to receive(:new).and_return(monitor)
        allow(monitor).to receive(:start)

        allow(subject).to receive(:say)
      end

      it "creates a new deployment and opens stack monitor" do
        expect(client).to receive(:run_command).with('deploy').and_return({deployment_id: 'derp'})
        expect(subject).to_not receive(:open_deploy)
        expect(Monitor::App).to receive(:new)

        subject.execute
      end

      it "opens the OpsWorks deployments screen if browser option is given" do
        expect(subject).to receive(:open_deploy)
        expect(Monitor::App).to_not receive(:new)

        subject.execute({ browser: true })
      end

      it "doesn't open the stack monitor or open the browser window when no-monitor options is given" do
        expect(subject).to_not receive(:open_deploy)
        expect(Monitor::App).to_not receive(:new)

        subject.execute({"no-monitor" => true})
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
