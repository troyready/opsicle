require "spec_helper"
require "opsicle"

describe Opsicle::Monitor::Screen do

  before do

    curses_test = double(
      "Curses",
      :init_screen  => nil,
      :close_screen => nil,
      :nl           => nil,
      :noecho       => nil,
      :curs_set     => nil,
      :timeout=     => nil,
      :refresh      => nil,
      :lines        => 24,
      :cols         => 80
    )
    stub_const "Curses", curses_test

    @panel = double(
      "@panel",
      :close       => nil,
      :panel_main= => nil
    )
    @panel_d = @panel.dup
    @panel_q = @panel.dup

    allow(Opsicle::Monitor::Panels::Header).to receive(:new).and_return(@panel)
    allow(Opsicle::Monitor::Panels::Deployments).to receive(:new).and_return(@panel_d)
    allow(Opsicle::Monitor::Panels::Help).to receive(:new).and_return(@panel_h)

    @screen = Opsicle::Monitor::Screen.new
  end

  describe "#initialize" do
    it "inits screen" do
      expect(Curses).to receive(:init_screen)

      Opsicle::Monitor::Screen.new
    end

    it "sets height" do
      expect(@screen.height).to equal(24)
    end

    it "sets width" do
      expect(@screen.width).to equal(80)
    end
  end

  describe "#close" do
    it "closes screen" do
      @screen.instance_variable_set(:@panels, { :panel => @panel })
      expect(Curses).to receive(:close_screen)

      @screen.close
    end

    it "closes panels" do
      @panel2 = double
      expect(@panel2).to receive(:close)

      @screen.instance_variable_set(:@panels, { :panel2 => @panel2 })

      @screen.close
    end
  end

  describe "#refresh" do
    it "refreshes panels" do
      @panel2 = double
      expect(@panel2).to receive(:refresh)

      @screen.instance_variable_set(:@panels, { :panel2 => @panel2 })

      @screen.refresh
    end
  end

  describe "#next_key" do
    it "gets next key" do
      expect(Curses).to receive(:getch)

      @screen.next_key
    end
  end

  describe "#missized?" do
    it "returns false when not missized" do
      expect(@screen).to receive(:term_height).and_return(24)
      expect(@screen).to receive(:term_width).and_return(80)

      expect(@screen.missized?).to equal(false)

    end

    it "returns true when missized" do
      expect(@screen).to receive(:term_height).and_return(21)
      # Width isn't checked before height

      expect(@screen.missized?).to equal(true)
    end
  end

  describe "#panel_main=" do
    before do
      @panels = @screen.instance_variable_get(:@panels)
    end

    it "defaults panel_main to deployments" do
      expect(@panels[:main]).to equal(@panel_d)
    end
  end

end
