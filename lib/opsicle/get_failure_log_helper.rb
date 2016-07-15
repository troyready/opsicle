# require 'yaml'

module Opsicle
  module GetFailureLogHelper
    def get_recent_failure_log(client, stack)
      stack_id = {stack_id: stack.stack_id}
      # client.describe_deployments(stack_id).deployments.select{ |d| !d.status.eql? "successful" }.first.deployment_id
      # system("open", client.describe_commands(deployment_id: deploy_id).commands[0].log_url)
    end
  end
end
