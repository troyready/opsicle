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
      failed_deployments = fetch_failed_deployments

      unless failed_deployments.empty?
        failed_deployment_id = failed_deployments.first.deployment_id
        failed_deployments_instances = failed_deployments.first.instance_ids

        involved_instance_id = fetch_instance_id(failed_deployments_instances)

        target_failed_command = fetch_target_command(involved_instance_id, failed_deployment_id)
        log_url = target_failed_command.first.log_url
        
        system("open", log_url) if log_url
        puts "Unable to find a url to open." unless log_url
      else
        puts "No failed deployments in available history."
      end
    end

    def fetch_failed_deployments
      deployments = @client.opsworks.describe_deployments(stack_id: @stack.stack_id).deployments
      deployments.select{ |deploy| deploy.status.eql? "failed" }
    end

    def fetch_instance_id(failed_deployments_instances)
      involved_instances = @client.opsworks.describe_instances(instance_ids: failed_deployments_instances).instances
      choice = select_instance(involved_instances)
      involved_instances[choice-1].instance_id
    end

    def fetch_target_command(involved_instance_id, failed_deployment_id)
      command_list = @client.opsworks.describe_commands(instance_id: involved_instance_id)[:commands]
      command_list.select{ |command| command.deployment_id == failed_deployment_id }
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
