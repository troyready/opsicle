module Opsicle
  class SSH
    attr_reader :client

    def initialize(environment)
      @client = Client.new(environment)
    end

    def execute(options={})
      if instances.length == 1
        choice = 1
      else
        Output.say "Choose an Opsworks instance:"
        instances.each_index do |x|
          Output.say "#{x+1}) #{instances[x][:hostname]}"
        end
        choice = Output.ask("? ", Integer) { |q| q.in = 1..instances.length }
      end

      instance_ip = instances[choice-1][:elastic_ip] || instances[choice-1][:public_ip]
      ssh_command = " \"#{options[:"ssh-cmd"].gsub(/'/){ %q(\') }}\"" if options[:"ssh-cmd"] #escape single quotes
      ssh_options = "#{options[:"ssh-opts"]} " if options[:"ssh-opts"]

      command = "ssh #{ssh_options}#{ssh_username}@#{instance_ip}#{ssh_command}"

      Output.say_verbose "Executing shell command: #{command}"
      system(command)
    end

    def instances
      @instances ||= client.api_call(:describe_instances, { stack_id: client.config.opsworks_config[:stack_id] })
                           .data[:instances]
                           .select { |instance| instance[:status].to_s == 'online'}
    end

    def ssh_username
      client.api_call(:describe_my_user_profile)[:user_profile][:ssh_username]
    end
  end
end
