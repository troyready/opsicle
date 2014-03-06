require 'highline/import'

module Opsicle
  module Output
    def self.say(msg, color_requested=nil)
      if $color && color_requested
        super "<%= color('#{msg}', #{color_requested}) %>"
      else
        super msg
      end
    end

    def self.say_verbose(msg, color="MAGENTA")
      self.say "<%= color('#{msg}', #{color}) %>" if $verbose
    end
  end
end
