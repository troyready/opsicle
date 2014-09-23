require 'opsicle/client'
require 'canis/core/util/app'

module Opsicle
  class Monitor
    def start
      App.new do
        @header = app_header "My App #{App::VERSION}", :text_center => "Opsicle Monitor REBORN!", :text_right =>"Some text", :color => :black, :bgcolor => :white

        @status_line = status_line
        @status_line.command {

        }
      end
    end
  end
end
