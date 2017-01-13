require "opsicle/user_profile"

module Opsicle
  class SSH
    attr_reader :client

    def initialize(environment)
      @client = Client.new(environment)
      @stack = Opsicle::Stack.new(@client)
      @user_profile = Opsicle::UserProfile.new(@client)
    end

    def execute(options={})

      if instances.length == 1
        choice = 1
      else
        Output.say "Choose an Opsworks instance:"
        instances.each_with_index do |instance, index|
          Output.say "#{index+1}) #{instance[:hostname]} #{instance_info(instance)}"
        end
        choice = Output.ask("? ", Integer) { |q| q.in = 1..instances.length }
      end

      command = ssh_command(instances[choice-1], options)

      Output.say_verbose "Executing shell command: #{command}"
      system(command)
    end

    def instances
      @instances ||= client.api_call(:describe_instances, { stack_id: client.config.opsworks_config[:stack_id] })[:instances]
                           .select { |instance| instance[:status].to_s == 'online'}
                           .sort { |a,b| a[:hostname] <=> b[:hostname] }
    end

    def public_ips
      instances.map{|instance| instance[:elastic_ip] || instance[:public_ip] }.compact
    end

    def ssh_username
      @user_profile.ssh_username
    end

    def ssh_ip(instance)
      if client.config.opsworks_config[:internal_ssh_only]
        Output.say "This stack requires a private connection, only using internal IPs."
        instance[:private_ip]
      else
        instance[:elastic_ip] || instance[:public_ip]
      end
    end

    def ssh_command(instance, options={})
      ssh_command = " \"#{options[:"ssh-cmd"].gsub(/'/){ %q(\') }}\"" if options[:"ssh-cmd"] #escape single quotes
      ssh_options = options[:"ssh-opts"] ? "#{options[:"ssh-opts"]} " : ""
      if instance_ip = ssh_ip(instance)
        ssh_string = "#{ssh_username}@#{instance_ip}"
      else
        ssh_string = "#{ssh_username}@#{public_ips.sample} ssh #{instance[:private_ip]}"
        ssh_options.concat('-A -t ')
      end

      "ssh #{ssh_options}#{ssh_string}#{ssh_command}"
    end

    def instance_info(instance)
      infos = []
      infos << instance[:layer_ids].map{ |layer_id| @stack.layer_name(layer_id) } if instance[:layer_ids]
      infos << "EIP" if instance[:elastic_ip]
      "(#{infos.join(', ')})"
    end

  end
end
