require "spec_helper"
require "opsicle"

module Opsicle
  describe ExecuteRecipes do
    subject { ExecuteRecipes.new('derp') }
    let(:recipes) { ['herp'] }

    context "#execute" do
      let(:client) { double }
      let(:monitor) { double(:start => nil) }
      before do
        allow(Client).to receive(:new).with('derp').and_return(client)
        allow(client).to receive(:run_command).with('execute_recipes', {"recipes" => ['herp']}, {}).and_return({deployment_id: 'derp'})

        allow(Monitor::App).to receive(:new).and_return(monitor)
        allow(monitor).to receive(:start)

        allow(Output).to receive(:say)
        allow(Output).to receive(:say_verbose)
      end

      it "creates a new execute_recipes deployment and opens stack monitor" do
        expect(client).to receive(:run_command).with('execute_recipes', {"recipes" => ['herp']}, {}).and_return({deployment_id: 'derp'})
        expect(subject).to_not receive(:open_deploy)
        expect(Monitor::App).to receive(:new)

        subject.execute({ monitor: true, recipes: recipes })
      end

      context "multiple recipes" do
        let(:recipes) { ['herp', 'flurp'] }
        it "creates a new execute_recipes deployment with multiple recipes" do
          expect(client).to receive(:run_command).with('execute_recipes', {"recipes" => ['herp', 'flurp']}, {}).and_return({deployment_id: 'derp'})
          expect(subject).to_not receive(:open_deploy)
          subject.execute({ monitor: false, recipes: recipes })
        end
      end

      context "instance_ids provided" do
        let(:instance_id) { "6df39ff7-711c-4a58-a64c-0b0e3195af73" }
        it "creates a new execute_recipes deployment for the specific instance_ids" do
          expect(client).to receive(:run_command).with('execute_recipes', {"recipes" => ['herp']}, {"instance_ids" => [instance_id]}).and_return({deployment_id: 'derp'})
          subject.execute({ monitor: false, instance_ids: [instance_id], recipes: recipes })
        end
      end

      it "opens the OpsWorks deployments screen if browser option is given" do
        expect(subject).to receive(:open_deploy)
        expect(Monitor::App).to_not receive(:new)

        subject.execute({ browser: true, recipes: recipes })
      end

      it "doesn't open the stack monitor or open the browser window when no-monitor option is given" do
        expect(subject).to_not receive(:open_deploy)
        expect(Monitor::App).to_not receive(:new)

        subject.execute({ monitor: false, recipes: recipes })
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
