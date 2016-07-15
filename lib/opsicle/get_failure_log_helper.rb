# require 'yaml'

module Opsicle
  module GetFailureLogHelper
    def get_recent_failure_log(client, stack)
      stack_id_hash = {stack_id: stack.id}
      deployments = client.opsworks.describe_deployments(stack_id_hash).deployments
      # puts deployments
      failed_deployments = deployments.select{ |d| !d.status.eql? "successful" }
      # puts failed_deployments
      failed_deployment_id = failed_deployments.first.deployment_id
      # puts failed_deployment_id
      resp = client.opsworks.describe_commands(deployment_id: failed_deployment_id)
      puts resp.commands.inspect
      # .commands[0]#.log_url

      # system("open", log_url)
    end
  end
end
