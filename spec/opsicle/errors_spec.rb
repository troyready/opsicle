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
        let(:deploy) { {:name => "update_custom_cookbooks"} }
        subject { DeployFailed.new(deploy) }

        it "updates the error message" do
          expect(subject.message).to eq('update_custom_cookbooks failed!')
        end
      end

      context "with an execute_recipes command passed in" do
        let(:deploy) { {:name => "execute_recipes", :args=>{"recipes"=>["app-configs", "deploy::default"]}} }
        subject { DeployFailed.new(deploy) }

        it "updates the error message" do
          expect(subject.message).to eq('execute_recipes (running [app-configs, deploy::default]) failed!')
        end
      end

      describe "#command_string" do
        context "if @command is nil" do
          it "returns 'deploy' if command is nil" do
            expect(subject.command_string).to eq('deploy')
          end
        end

        context "if @command is update_custom_cookbooks" do
          let(:deploy) { {:name => "update_custom_cookbooks"} }
          subject { DeployFailed.new deploy }

          it "returns 'update_custom_cookbooks'" do
            expect(subject.command_string).to eq('update_custom_cookbooks')
          end
        end

        context "if @command is execute_recipes" do
          let(:deploy) { {:name => "execute_recipes", :args=>{"recipes"=>["app-configs", "deploy::default"]}} }
          subject { DeployFailed.new deploy }

          it "returns 'execute_recipes (running [app-configs, deploy::default])'" do
            expect(subject.command_string).to eq('execute_recipes (running [app-configs, deploy::default])')
          end
        end
      end
    end

  end
end
