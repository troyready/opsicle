require 'highline/import'

module Opsicle
  module Helpers
    def tell(msg, color="YELLOW")
      if $color
        say "<%= color('#{msg}', #{color}) %>"
      else
        say msg
      end
    end

    def tell_verbose(msg, color="MAGENTA")
      if $color && $verbose
        say "<%= color('#{msg}', #{color}) %>"
      elsif $verbose
        say msg
      end
    end
  end
end
