require "spec_helper"
require "opsicle"

module Opsicle
  describe SSH do
    subject { SSH.new('derp') }
    let(:client) { double(config: double(opsworks_config: {stack_id: "1234"})) }
    let(:api_call) { double }
    before do
      allow(Client).to receive(:new).with('derp').and_return(client)
    end

    context "#execute" do
      before do
        allow(Output).to receive(:say)
        allow(Output).to receive(:say_verbose)
        allow(Output).to receive(:ask).and_return(2)
        allow(subject).to receive(:ssh_username) {"mrderpyman2014"}
      end

      it "executes ssh with a selected Opsworks instance IP" do
        allow(subject).to receive(:instances) {[
                                    { hostname: "host1", elastic_ip: "123.123.123.123" },
                                    { hostname: "host2", elastic_ip: "789.789.789.789" }
                                  ]}

        expect(subject).to receive(:system).with("ssh mrderpyman2014@789.789.789.789")
        subject.execute
      end

      it "executes ssh with public_ip listings as well as elastic_ip" do
        allow(subject).to receive(:instances) {[
                                    { hostname: "host1", elastic_ip: "678.678.678.678" },
                                    { hostname: "host2", public_ip: "987.987.987.987" }
                                  ]}

        expect(subject).to receive(:system).with("ssh mrderpyman2014@987.987.987.987")
        subject.execute
      end

      it "executes ssh favoring an elastic_ip over a public_ip if both exist" do
        allow(subject).to receive(:instances) {[
                                    { hostname: "host1", elastic_ip: "678.678.678.678" },
                                    { hostname: "host2", public_ip: "987.987.987.987", elastic_ip: "132.132.132.132" }
                                  ]}

        expect(subject).to receive(:system).with("ssh mrderpyman2014@132.132.132.132")
        subject.execute
      end

      it "executes ssh right away if there is only one Opsworks instance available" do
        allow(subject).to receive(:instances) {[
                                    { hostname: "host3", elastic_ip: "456.456.456.456" }
                                  ]}

        expect(subject).to receive(:system).with("ssh mrderpyman2014@456.456.456.456")
        expect(subject).not_to receive(:ask)
        subject.execute
      end

      it "executes ssh with ssh options and command" do
        allow(subject).to receive(:instances) {[
                                    { hostname: "host1", elastic_ip: "123.123.123.123" },
                                    { hostname: "host2", elastic_ip: "789.789.789.789" }
                                  ]}

        expect(subject).to receive(:system).with("ssh -p 234 mrderpyman2014@789.789.789.789 \"cd /srv/www\"")
        subject.execute({ :"ssh-opts" => '-p 234', :"ssh-cmd" => 'cd /srv/www'})
      end

    end

    context "#client" do
      it "generates a new aws client from the given configs" do
        expect(Client).to receive(:new).with('derp')
        subject.client
      end
    end

    context "#instances" do
      it "makes a describe_instances API call" do
        expect(client).to receive(:api_call).with(:describe_instances, {stack_id: "1234"})
          .and_return(api_call)
        expect(api_call).to receive(:data).and_return(instances: {:foo => :bar})
        expect(subject.instances).to eq({:foo => :bar})
      end
    end

    context "#ssh_username" do
      it "makes a describe_my_user_profile API call" do
        allow(client).to receive(:api_call).with(:describe_my_user_profile)
          .and_return({user_profile: {:ssh_username => "captkirk01"}})
        expect(subject.ssh_username).to eq("captkirk01")
      end
    end

  end
end
