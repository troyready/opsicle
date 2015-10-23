module Opsicle
  class ChefLog

    def initialize(environment)
      @ssh = SSH.new(environment)
    end

    def execute(options={})
      instance = @ssh.choose_instance(options[:hostname])
      list_command = @ssh.ssh_command(instance, :"ssh-cmd" => "sudo ls -1t /var/lib/aws/opsworks/chef/ | grep log")

      Output.say_verbose "Executing shell command: #{list_command}"
      files = `#{list_command}`
      file = choose_log(files.split("\n"))

      view_command = @ssh.ssh_command(instance, :"ssh-cmd" => "sudo cat /var/lib/aws/opsworks/chef/#{file}")
      Output.say_verbose "Executing shell command: #{view_command}"
      system("#{view_command} | less")
    end

    def choose_log(files)
      if files.length == 1
        choice = 1
      else
        Output.say "Choose Chef log file:"
        files.each_with_index do |file, index|
          Output.say "#{index+1}) #{file}"
        end
        choice = Output.ask("? ", Integer) { |q| q.in = 1..files.length }
      end
      files[choice-1]
    end

  end
end
