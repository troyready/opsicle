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
        instances.each_with_index do |instance, index|
          Output.say "#{index+1}) #{instance[:hostname]}"
        end
        choice = Output.ask("? ", Integer) { |q| q.in = 1..instances.length }
      end

      ssh_command = " \"#{options[:"ssh-cmd"].gsub(/'/){ %q(\') }}\"" if options[:"ssh-cmd"] #escape single quotes
      ssh_options = options[:"ssh-opts"] ? "#{options[:"ssh-opts"]} " : ""

      instance = instances[choice-1]
      if instance_ip = instance[:elastic_ip] || instance[:public_ip]
        ssh_string = "#{ssh_username}@#{instance_ip}"
      else
        ssh_string = "#{ssh_username}@#{public_ips.sample} ssh #{instance[:private_ip]}"
        ssh_options.concat('-A -t ')
      end

      command = "ssh #{ssh_options}#{ssh_string}#{ssh_command}"

      Output.say_verbose "Executing shell command: #{command}"
      system(command)
    end

    def instances
      @instances ||= client.api_call(:describe_instances, { stack_id: client.config.opsworks_config[:stack_id] })
                           .data[:instances]
                           .select { |instance| instance[:status].to_s == 'online'}
    end

    def public_ips
      instances.map{|instance| instance[:elastic_ip] || instance[:public_ip] }.compact
    end

    def ssh_username
      client.api_call(:describe_my_user_profile)[:user_profile][:ssh_username]
    end
  end
end
