require "spec_helper"
require "opsicle"
require "curses"

describe Opsicle::Monitor::Panel do

  before do
    @window = double

    allow(Curses::Window).to receive(:new).and_return(@window)

    @panel = Opsicle::Monitor::Panel.new(24, 80, 1, 2)
  end

  describe "#initialize" do
    describe "required" do
      it "sets height" do
        expect(@panel.height).to equal(24)
      end

      it "sets width" do
        expect(@panel.width).to equal(80)
      end

      it "sets top" do
        expect(@panel.top).to equal(1)
      end

      it "sets left" do
        expect(@panel.left).to equal(2)
      end

      it "defaults dividers" do
        expect(@panel.dividers).to eq({
          :left => '',
          :right => '',
        })
      end

      it "calculates divider_length" do
        expect(@panel.divider_length).to equal(0)
      end


      it "sets up window with dimensions" do
        expect(Curses::Window).to receive(:new).with(24,80,1,2)

        Opsicle::Monitor::Panel.new(24, 80, 1, 2)
      end

      it "sets window" do
        expect(@panel.instance_variable_get(:@window)).to eq(@window)
      end
    end

    describe "optional" do
      before do
        @structure = [
          [
            [1, "busy:",    -> { 1 + 3 }], # S(0,0)
            [1, "retries:", 2],  # S(0,1)
          ],
          [
            [2, -> { 2 * 7 },     "long"],  # S(1,0)
            [1, -> { "1" + "4" }, -> { "dark" }], # S(1,1)
          ],
        ]

        @panel = Opsicle::Monitor::Panel.new(24, 80, 1, 2, @structure,
          :divider_l => '<',
          :divider_r => '>'
        )

        @subpanels = @panel.instance_variable_get(:@subpanels)
      end

      it "sets dividers" do
        expect(@panel.dividers).to eq({
          :left  => '<',
          :right => '>',
        })
      end

      it "calculates divider_length" do
        expect(@panel.divider_length).to equal(2)
      end

      it "builds enough subpanels" do
        expect(@subpanels.length).to equal(4)
      end

      it "builds S(0,0)" do
        expect(@subpanels.count { |e|
          e.height == 1 && e.width == 42 && e.top == 0 && e.left == 0 &&
          e.data[:left] == "busy:" && e.data[:right].call == 4 &&
          e.dividers[:left] == '' && e.dividers[:right] == '>' &&
          e.content_width == 41
        }).to equal(1)
      end

      it "builds S(0,1)" do
        expect(@subpanels.count { |e|
          e.height == 1 && e.width == 38 && e.top == 0 && e.left == 42 &&
          e.data[:left] == "retries:" && e.data[:right] == 2 &&
          e.dividers[:left] == '<' && e.dividers[:right] == '' &&
          e.content_width == 37
        }).to equal(1)
      end

      it "builds S(1,0)" do
        expect(@subpanels.count { |e|
          e.height == 1 && e.width == 56 && e.top == 1 && e.left == 0 &&
          e.data[:left].call == 14 && e.data[:right] == "long" &&
          e.dividers[:left] == '' && e.dividers[:right] == '>' &&
          e.content_width == 55
        }).to equal(1)
      end

      it "builds S(1,1)" do
        expect(@subpanels.count { |e|
          e.height == 1 && e.width == 24 && e.top == 1 && e.left == 56 &&
          e.data[:left].call == "14" && e.data[:right].call == "dark" &&
          e.dividers[:left] == '<' && e.dividers[:right] == '' &&
          e.content_width == 23
        }).to equal(1)
      end
    end
  end

  describe "#close" do
    it "closes window" do
      expect(@window).to receive(:close)

      @panel.close
    end
  end

  describe "#refresh" do
    it "refreshes subpanels" do
      allow(@window).to receive(:refresh)

      @subpanel2 = double
      expect(@subpanel2).to receive(:refresh)

      @panel.instance_variable_set(:@subpanels, [@subpanel2])

      @panel.refresh
    end

    it "refreshes window" do
      @subpanel2 = double(:refresh => nil)

      @panel.instance_variable_set(:@subpanels, [@subpanel2])

      expect(@window).to receive(:refresh)

      @panel.refresh
    end
  end

end
