module Opsicle
  class GetFailureLog
    attr_reader :client, :stack

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
      @stack = Opsicle::Stack.new(@client)
    end

    def execute
      puts "Getting most recent failure log..."

      stack_id_hash = {stack_id: @stack.stack_id}
      deployments = @client.opsworks.describe_deployments(stack_id_hash).deployments
      failed_deployments = deployments.select{ |deploy| !deploy.status.eql? "successful" }
      failed_deployment_id = failed_deployments.first.deployment_id
      command_list = @client.opsworks.describe_commands(deployment_id: failed_deployment_id)
      log_url = command_list[:commands].first.log_url

      system("open", log_url)
    end
  end
end
