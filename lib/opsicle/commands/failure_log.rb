module Opsicle
  class FailureLog
    attr_reader :client, :stack

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
      @stack = Opsicle::Stack.new(@client)
    end

    def execute
      puts "Getting most recent failure log..."

      fetch
    end

    def fetch
      failed_deployment_id, failed_deployments_instances = fetch_deployments
      involved_instance_id = fetch_instances(failed_deployments_instances)
      log_url = fetch_commands(involved_instance_id, failed_deployment_id)
      system("open", log_url) if log_url
    end

    def fetch_deployments
      deployments = @client.opsworks.describe_deployments(stack_id: @stack.stack_id).deployments
      failed_deployments = deployments.select{ |deploy| !deploy.status.eql? "successful" }
      failed_deployment_id = failed_deployments.first.deployment_id
      failed_deployments_instances = failed_deployments.first.instance_ids

      return failed_deployment_id, failed_deployments_instances
    end

    def fetch_instances(failed_deployments_instances)
      involved_instances = @client.opsworks.describe_instances(instance_ids: failed_deployments_instances).instances
      choice = select_instance(involved_instances)
      return involved_instances[choice-1].instance_id
    end

    def fetch_commands(involved_instance_id, failed_deployment_id)
      command_list = @client.opsworks.describe_commands(instance_id: involved_instance_id)[:commands]
      target_failed_command = command_list.select{ |command| command.deployment_id == failed_deployment_id }
      return target_failed_command.first.log_url
    end

    def select_instance(instance_list)
      if instance_list.length == 1
        choice = 1
      else
        Output.say "Choose an Opsworks instance:"
        instance_list.each_with_index do |instance, index|
          Output.say "#{index+1}) #{instance[:hostname]}"
        end
        choice = Output.ask("? ", Integer) { |q| q.in = 1..instance_list.length }
      end
      return choice
    end
  end
end
