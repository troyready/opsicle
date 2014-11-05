require 'gli/exceptions'

module Opsicle
  module Errors

    class DeployFailed < StandardError
      def initialize(command=nil)
        @command = command
        super("#{command_string} failed!")
      end

      def command_string
        command_string = @command ? @command[:name] : 'deploy'

        if command_string == 'execute_recipes' && @command[:args]["recipes"]
          command_string += " (running [#{@command[:args]["recipes"].join(', ')}])"
        end

        command_string
      end
    end

  end
end
