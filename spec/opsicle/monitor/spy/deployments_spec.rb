require 'spec_helper'
require 'opsicle'

describe Opsicle::Monitor::Spy::Deployments do
  before do
    @deployments = double(:data => {})

    expect(Opsicle::Deployments).to receive(:new).and_return(@deployments)

    @subject = Opsicle::Monitor::Spy::Deployments.new
  end

  describe "#user_from_arn" do
    it "parses a normal user string" do
      result = @subject.user_from_arn("arn:aws:iam::465198754621:user/chris.arcand")
      expect(result).to eq("chris.arcand")
    end

    it "parses a root user string" do
      result = @subject.user_from_arn("arn:aws:iam::465198754621:root")
      expect(result).to eq("root")
    end

    it "handles an unknown string gracefully" do
      result = @subject.user_from_arn("Ugly string")
      expect(result).to eq("Ugly string")
    end

    it "handles a nil or empty string gracefully" do
      nilstring = @subject.user_from_arn(nil)
      emptystring = @subject.user_from_arn("")

      expect(nilstring).to eq("")
      expect(nilstring).to eq("")
    end
  end
end
