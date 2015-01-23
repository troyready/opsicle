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

      it "executes sshs through an instance with a public_ip to get to one with a private_ip" do
        allow(subject).to receive(:instances) {[
                            { hostname: "host1", elastic_ip: "123.123.123.123" },
                            { hostname: "host2", private_ip: "789.789.789.789" }
                          ]}
        expect(subject).to receive(:system).with("ssh -A -t mrderpyman2014@123.123.123.123 ssh 789.789.789.789")
        subject.execute
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
        expect(api_call).to receive(:data).and_return(instances: [{:name => :foo, :status => "online"},{:name => :bar, :status => "stopped"}])
        expect(subject.instances).to eq([{:name => :foo, :status=>"online"}])
      end
    end

    context "#ssh_username" do
      it "makes a describe_my_user_profile API call" do
        allow(client).to receive(:api_call).with(:describe_my_user_profile)
          .and_return({user_profile: {:ssh_username => "captkirk01"}})
        expect(subject.ssh_username).to eq("captkirk01")
      end
    end

    context "#public_ips" do
      it "selects all EIPs and then public_ip on the stack" do
        allow(subject).to receive(:instances) {[
                    { hostname: "host1", elastic_ip: "123.123.123.123", public_ip: "123.345.567.789"},
                    { hostname: "host2", public_ip: "456.456.456.456" },
                    { hostname: "host2", private_ip: "789.789.789.789" },
                  ]}
        expect(subject.public_ips).to eq(["123.123.123.123","456.456.456.456"])
      end
    end

    context "#ssh_command" do
      before do
        allow(subject).to receive(:ssh_username) {"mrderpyman2014"}
        allow(subject).to receive(:instances) {[
                    { hostname: "host1", elastic_ip: "123.123.123.123" },
                    { hostname: "host2", private_ip: "789.789.789.789" }
                  ]}
      end
      it "creates the proper ssh_command for an instance with a public/elastic ip" do
        expect(subject.ssh_command({elastic_ip: "123.123.123.123" })).to eq("ssh mrderpyman2014@123.123.123.123")
      end
      it "creates the proper ssh_command for an instance with a private ip" do
        expect(subject.ssh_command({private_ip: "789.789.789.789" })).to eq("ssh -A -t mrderpyman2014@123.123.123.123 ssh 789.789.789.789")
      end
      it "properly adds ssh options to the ssh_command for an isntance with a public ip" do
        expect(subject.ssh_command({elastic_ip: "123.123.123.123" }, { :"ssh-opts" => "-c"})).to eq("ssh -c mrderpyman2014@123.123.123.123")
      end
      it "properly adds ssh options to the ssh_command for an isntance with a private ip" do
        expect(subject.ssh_command({private_ip: "789.789.789.789"}, { :"ssh-opts" => "-c"} )).to eq("ssh -c -A -t mrderpyman2014@123.123.123.123 ssh 789.789.789.789")
      end
    end
  end
end
