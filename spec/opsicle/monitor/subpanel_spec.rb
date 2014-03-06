require "spec_helper"
require "opsicle"


describe Opsicle::Monitor::Subpanel do

  describe "#initialize" do
    describe "required" do
      before do
        @window = double

        @subpanel = Opsicle::Monitor::Subpanel.new(@window, 24, 80, 1, 2)
      end

      it "sets window" do
        expect(@subpanel.instance_variable_get(:@window)).to equal(@window)
      end

      it "sets height" do
        expect(@subpanel.height).to equal(24)
      end

      it "sets width" do
        expect(@subpanel.width).to equal(80)
      end

      it "sets top" do
        expect(@subpanel.top).to equal(1)
      end

      it "sets left" do
        expect(@subpanel.left).to equal(2)
      end

      it "defaults data" do

        expect(@subpanel.data).to eq({
          :left  => '',
          :right => '',
        })
      end

      it "defaults dividers" do
        expect(@subpanel.dividers).to eq({
          :left  => '',
          :right => '',
        })
      end

      it "calculates content_width" do
        expect(@subpanel.content_width).to equal(80)
      end
    end

    describe "optional" do
      before do
        @subpanel = Opsicle::Monitor::Subpanel.new(double, 24, 80, 1, 2, {
          :data_l    => 'key:',
          :data_r    => 'value',
          :divider_l => '<',
          :divider_r => '/>',
        })
      end

      it "sets data" do
        expect(@subpanel.data).to eq({
          :left  => 'key:',
          :right => 'value',
        })
      end

      it "sets dividers" do
        expect(@subpanel.dividers).to eq({
          :left  => '<',
          :right => '/>',
        })
      end

      it "calculates content_width" do
        expect(@subpanel.content_width).to equal(77)
      end
    end
  end

  describe "#refresh" do
    describe "strings and dividers" do
      before do
        @window = double

        @subpanel = Opsicle::Monitor::Subpanel.new(@window, 24, 80, 1, 2, {
          :data_l    => 'key:',
          :data_r    => 'value',
          :divider_l => '<-',
          :divider_r => '|',
        })
      end

      describe "when changed" do
        it "sets position" do
          allow(@window).to receive(:addstr)

          expect(@window).to receive(:setpos).with(1, 2)

          @subpanel.refresh
        end

        it "sets data" do
          allow(@window).to receive(:setpos)

          expect(@window).to receive(:addstr).with("<-key:                                                                    value|")

          @subpanel.refresh
        end

        it "sets truncated data when too long" do
          @subpanel = Opsicle::Monitor::Subpanel.new(@window, 24, 10, 1, 2, {
            :data_l    => 'key:',
            :data_r    => 'value',
            :divider_l => '<-',
            :divider_r => '|',
          })

          allow(@window).to receive(:setpos)

          expect(@window).to receive(:addstr).with("<-key:val|")

          @subpanel.refresh
        end
      end

      describe "when unchanged" do
        before do
          allow(@window).to receive(:setpos)
          allow(@window).to receive(:addstr)

          @subpanel.refresh
        end

        it "skips position" do
          expect(@window).not_to receive(:setpos)

          @subpanel.refresh
        end

        it "skips data" do
          expect(@window).not_to receive(:addstr)

          @subpanel.refresh
        end
      end
    end

    describe "lambdas" do
      before do
        @window = double

        @subpanel = Opsicle::Monitor::Subpanel.new(@window, 24, 80, 0, 0, {
          :data_l => -> { "the answer:" },
          :data_r => -> { "42" }
        })
      end

      it "sets data when changed" do
        allow(@window).to receive(:setpos)

        expect(@window).to receive(:addstr).with("the answer:                                                                   42")

        @subpanel.refresh
      end

      it "sets data when non-string" do
        @subpanel = Opsicle::Monitor::Subpanel.new(@window, 24, 10, 0, 0, {
          :data_l => -> { 2 * 3 * 7 },
          :data_r => -> { 42 }
        })

        allow(@window).to receive(:setpos)

        expect(@window).to receive(:addstr).with("42      42")

        @subpanel.refresh
      end

      it "sets empty data when nil" do
        @subpanel = Opsicle::Monitor::Subpanel.new(@window, 24, 10, 0, 0, {
          :data_l => -> { nil },
          :data_r => -> { nil }
        })

        allow(@window).to receive(:setpos)

        expect(@window).to receive(:addstr).with("          ")

        @subpanel.refresh
      end
    end
  end

end
