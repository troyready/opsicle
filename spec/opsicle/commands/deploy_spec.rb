require "spec_helper"
require "opsicle"

module Opsicle
  describe Deploy do
    subject { Deploy.new('derp') }

    context "#execute" do
      let(:client) { double }
      let(:monitor) { double(:start => nil) }
      before do
        allow(Client).to receive(:new).with('derp').and_return(client)
        allow(client).to receive(:run_command).with('deploy', {}).and_return({deployment_id: 'derp'})

        allow(Monitor::App).to receive(:new).and_return(monitor)
        allow(monitor).to receive(:start)

        allow(Output).to receive(:say)
        allow(Output).to receive(:say_verbose)
      end

      it "creates a new deployment and opens stack monitor" do
        expect(client).to receive(:run_command).with('deploy', {}).and_return({deployment_id: 'derp'})
        expect(subject).to_not receive(:open_deploy)
        expect(Monitor::App).to receive(:new).with('derp', :monitor => true)

        subject.execute
      end

      it "creates a new deployment that exits the stack monitor on completion" do
        expect(client).to receive(:run_command).with('deploy', {}).and_return({deployment_id: 'derp'})
        expect(subject).to_not receive(:open_deploy)
        expect(Monitor::App).to receive(:new).with('derp', :monitor => true, :deployment_id => 'derp')

        subject.execute({:monitor => true, :track => true})
      end

      it "creates a new deployment with migrations" do
        expect(client).to receive(:run_command).with('deploy', {"migrate"=>["true"]}).and_return({deployment_id: 'derp'})
        expect(subject).to_not receive(:open_deploy)
        subject.execute({ monitor: false, migrate: true })
      end

      it "creates a new deployment migrations explicitly disabled" do
        expect(client).to receive(:run_command).with('deploy', {}).and_return({deployment_id: 'derp'})
        expect(subject).to_not receive(:open_deploy)
        subject.execute({ monitor: false, migrate: false })
      end

      it "opens the OpsWorks deployments screen if browser option is given" do
        expect(subject).to receive(:open_deploy)
        expect(Monitor::App).to_not receive(:new)

        subject.execute({ browser: true })
      end

      it "doesn't open the stack monitor or open the browser window when no-monitor option is given" do
        expect(subject).to_not receive(:open_deploy)
        expect(Monitor::App).to_not receive(:new)

        subject.execute({ monitor: false })
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
