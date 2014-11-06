require "spec_helper"
require "opsicle"

module Opsicle
  describe ExecuteRecipes do
    subject { ExecuteRecipes.new('derp') }
    let(:recipes) { ['herp'] }
    let(:client) { double }
    let(:monitor) { double(:start => nil) }

    context "#execute" do
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

    context "#determine_instance_ids" do
      before do
        allow(Client).to receive(:new).with('derp').and_return(client)
      end

      it "returns the instance_ids when passed in through options" do
        options = {:instance_ids => ["abcdefg","1234567"]}
        expect(subject.determine_instance_ids(options)).to eq(["abcdefg","1234567"])
      end

      it "returns the instance_ids when a layer is passed in" do
        options = {:layers => ["main-util"]}
        expect(subject).to receive(:determine_from_layers)
        subject.determine_instance_ids(options)
      end

      it "returns an instance_id when eip is set to true" do
        options = {:eip => true}
        expect(subject).to receive(:determine_from_eip)
        subject.determine_instance_ids(options)
      end

      it "returns an instance_id when an ip is passed in" do
        options = {:ip_addresses => true}
        expect(subject).to receive(:determine_from_ips)
        subject.determine_instance_ids(options)
      end
    end

    context "#determine_from_layer" do
      let(:layers) {["main-util"]}
      before do
        allow(Client).to receive(:new).with('derp').and_return(client)
      end

      it "returns the instance_ids when a layer is passed in" do
        allow(Opsicle::Layer).to receive(:instance_ids).and_return(["a1b2c3"])
        expect(subject.determine_from_layers(layers)).to eq(["a1b2c3"])
      end
    end

    context "#determine_from_ips" do
      let(:ips) {['1.2.3.4','5.6.7.8']}
      before do
        allow(Client).to receive(:new).with('derp').and_return(client)
      end

      it "returns an instance_id when an ip is passed in" do
        allow(Opsicle::Instances).to receive(:find_by_ip).and_return([{instance_id: "a1b2c3"}, {instance_id: "1234567"}])
        expect(subject.determine_from_ips(ips)).to eq(["a1b2c3","1234567"])
      end
    end

    context "#determine_from_eip" do
      before do
        allow(Client).to receive(:new).with('derp').and_return(client)
      end
      it "returns an instance_id when eip is set to true" do
        eip = true
        allow(Opsicle::Instances).to receive(:find_by_eip).and_return([{instance_id: "a1b2c3"}, {instance_id: "1234567"}])
        expect(subject.determine_from_eip).to eq("a1b2c3")
      end
    end

  end
end
