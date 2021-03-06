require "spec_helper"
require "opsicle"

describe Opsicle::Monitor::App do

  before do
    @screen = double(
      :close     => nil,
      :refresh   => nil,
      :next_key  => nil,
      :refresh_spies => nil,
      :missized? => nil
    )

    @client = double

    allow(Opsicle::Monitor::Screen).to receive(:new).and_return(@screen)
    allow(Opsicle::Client).to receive(:new).and_return(@client)

    @app = Opsicle::Monitor::App.new("staging", {})
  end

  describe "#initialize" do

    it "sets status not-running" do
      expect(@app.running).to equal(false)
    end

    it "sets status not-restarting" do
      expect(@app.restarting).to equal(false)
    end

    it "raises error without a tty" do
      expect($stdout).to receive(:tty?) { false }
      expect { Opsicle::Monitor::App.new("staging", {}) }.to raise_error(RuntimeError, "Monitor requires a TTY.")
    end

    context "when the app is montoring a deploy" do
      before do
        @app = Opsicle::Monitor::App.new("staging", {:deployment_id => 123})
      end

      it "set the deployment_id" do
        expect(@app.deployment_id).to equal(123)
      end

      it "assigns a deploy" do
        expect(@app.deploy).to be_an_instance_of(Opsicle::Deployment)
      end

      it "works without a tty for a deployment" do
        allow($stdout).to receive(:tty?) { false }
        Opsicle::Monitor::App.new("staging", {:deployment_id => 123})
      end
    end

  end

  describe "#restart" do
    before do
      @app.instance_variable_set(:@restarting, false)
    end

    it "sets status restarting" do
      @app.restart

      expect(@app.restarting).to equal(true)
    end
  end

  describe "#stop" do
    before do
      @app.instance_variable_set(:@running, true)
      @app.instance_variable_set(:@screen, @screen)
    end

    it "sets @running to false" do
      @app.stop rescue nil # don't care about the error here
      expect(@app.running).to eq(false)
    end

    context "when called normally" do
      it "raises QuitMonitor and exits safely without a message" do
        expect { @app.stop }.to raise_error(Opsicle::Monitor::QuitMonitor, "")
      end
    end

    context "when a message is passed in" do
      it "raises QuitMonitor and exists with message" do
        expect { @app.stop(message: "Hey!") }.to raise_error(Opsicle::Monitor::QuitMonitor, "Hey!")
      end
    end

    context "when a custom error is passed in" do
      it "raises the custom error" do
        MyAwesomeCustomError = Class.new(StandardError)
        expect { @app.stop(error: MyAwesomeCustomError) }.to raise_error(MyAwesomeCustomError)
      end
    end
  end

  describe "#do_command" do
    before do
      @app.instance_variable_set(:@running, true)
      @app.instance_variable_set(:@screen, @screen)
    end

    it "<d> switches to Deployments panel" do
      expect(@screen).to receive(:panel_main=).with(:deployments)

      @app.do_command('d')
    end

    it "<h> switches to Help panel" do
      expect(@screen).to receive(:panel_main=).with(:help)

      @app.do_command('h')
    end
  end

  describe "#check_deploy_status" do
    let(:deploy) { Opsicle::Deployment.new('derp', 'client') }
    let(:deployment) { double("deployment", :[] => 'running') }

    before do
      allow(deploy).to receive(:deployment).and_return(deployment)
      allow(deploy).to receive(:command).and_return({:name => 'deploy' })
      @app = Opsicle::Monitor::App.new("staging", {:deployment_id => 123})
      @app.instance_variable_set :@deploy, deploy
    end

    context "if the deploy is still running" do
      it "does not stop the monitor" do
        expect(@app).to receive(:stop).never
        @app.send :check_deploy_status
      end
    end

    context "if is finished running" do
      context "and ran successfully" do
        let(:deployment) { double("deployment", :[] => 'successful') }

        it "stops the monitor normally" do
          expect(@app).to receive(:stop).with(message: "Deploy completed successfully")
          @app.send :check_deploy_status
        end
      end

      context "and failed" do
        let(:deployment) { double("deployment", :[] => 'failed') }

        it "stops the monitor with an DeployFailed error" do
          expect(@app).to receive(:stop).with(error: Opsicle::Errors::DeployFailed)
          @app.send :check_deploy_status
        end
      end
    end
  end

end
