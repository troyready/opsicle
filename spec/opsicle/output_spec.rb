require "spec_helper"
require "opsicle"

module Opsicle
  describe Output do
    subject { Output }
    let(:terminal) { double(:say => nil, :color => nil) }
    let(:msg) { "message" }
    let(:colored_msg) { "COLOURmessageCOLOUR" }

    before do
      allow(subject).to receive(:terminal).and_return(terminal)
      $color = true
      $verbose = false
    end

    context "#say" do
      it "should say a formatted message" do
        allow(terminal).to receive(:color).and_return(colored_msg)
        expect(terminal).to receive(:say).with(colored_msg)
        subject.say(msg)
      end
      it "should say a message without color" do
        $color = false
        expect(terminal).to receive(:say).with(msg)
        subject.say(msg)
      end
    end

    context "#format" do
      it "should color message" do
        allow(terminal).to receive(:color).and_return(colored_msg)
        expect(subject.format(msg)).to eq(colored_msg)
      end
      it "should not color message" do
        $color = false
        expect(subject.format(msg)).to eq(msg)
      end
    end

    context "#say_verbose" do
      it "should not say a verbose message" do
        expect(terminal).to_not receive(:say)
        subject.say_verbose(msg)
      end
      it "should say a verbose message" do
        $verbose = true
        expect(terminal).to receive(:say)
        subject.say_verbose(msg)
      end
    end

    context "#ask" do
      it "should ask" do
        expect(terminal).to receive(:ask)
        subject.ask
      end
    end

  end
end