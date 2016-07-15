module Opsicle
  module GetFailureLogHelper

    # Will open in a browser the failure log from the most recent deployment that failed for
    # a given stack
    def get_recent_failure_log(client, stack)
      stack_id_hash = {stack_id: stack.stack_id}

      deployments = client.opsworks.describe_deployments(stack_id_hash).deployments
      failed_deployments = deployments.select{ |deploy| !deploy.status.eql? "successful" }
      failed_deployment_id = failed_deployments.first.deployment_id

      command_list = client.opsworks.describe_commands(deployment_id: failed_deployment_id)
      log_url = command_list[:commands].first.log_url

      system("open", log_url)
    end
  end
end
