require "spec_helper"
require "opsicle"

module Opsicle
  module Errors

    describe DeployFailed do
      let(:deploy) { {:name=>"deploy"} }

      it "set's it default message to 'deploy failed!'" do
        expect(subject.message).to eq('deploy failed!')
      end

      context "with a custom command passed in" do
        let(:deploy) { {:name => "chef-update"} }
        subject { DeployFailed.new(deploy) }

        it "updates the error message" do
          expect(subject.message).to eq('chef-update failed!')
        end
      end

      context "with a custom command passed in" do
        let(:deploy) { {:name => "execute-recipes", :args=>{"recipes"=>["app-configs", "deploy::default"]}} }
        subject { DeployFailed.new(deploy) }

        it "updates the error message" do
          expect(subject.message).to eq('execute-recipes (running [app-configs, deploy::default]) failed!')
        end
      end

      describe "#command_string" do
        context "if @command is nil" do
          it "returns 'deploy' if command is nil" do
            expect(subject.command_string).to eq('deploy')
          end
        end

        context "if @command is chef-update" do
          let(:deploy) { {:name => "chef-update"} }
          subject { DeployFailed.new deploy }

          it "returns 'chef-update'" do
            expect(subject.command_string).to eq('chef-update')
          end
        end

        context "if @command is execute-recipes" do
          let(:deploy) { {:name => "execute-recipes", :args=>{"recipes"=>["app-configs", "deploy::default"]}} }
          subject { DeployFailed.new deploy }

          it "returns 'execute-recipes (running [app-configs, deploy::default])'" do
            expect(subject.command_string).to eq('execute-recipes (running [app-configs, deploy::default])')
          end
        end
      end
    end

  end
end
