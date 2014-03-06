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

  it "sets status not-running" do
    expect(@app.running).to equal(false)
  end

  it "sets status not-restarting" do
    expect(@app.restarting).to equal(false)
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

end
