require 'curses'

module Opsicle
  module Monitor
    class Screen

      attr_reader :height
      attr_reader :width

      def initialize
        Curses.init_screen
        Curses.nl
        Curses.noecho
        Curses.curs_set(0)

        @height = term_height
        @width  = term_width

        @panels = { # attach panels, defining height, width, top, left
          :header        => Monitor::Panels::Header.new(      6, @width, 0, 0),
        }

        self.panel_main = :deployments

        Curses.refresh
      rescue
        close

        raise
      end

      def close
        @panels.each { |pname, panel| panel.close } if @panels

        Curses.close_screen
      end

      def refresh
        @panels.each { |pname, panel| panel.refresh }
      end

      def refresh_spies
        @panels.each { |pname, panel| panel.refresh_spies }
      end

      def next_key
        Curses.getch
      end

      def missized?
        @height != term_height || @width != term_width
      end

      def panel_main
        @panels[:header].panel_main
      end

      def panel_main=(pname)
        @panels[:header].panel_main = pname

        @panels[:main].close if @panels[:main]

        @panels[:main] = case pname
        when :deployments
          Monitor::Panels::Deployments.new((@height - 4), @width, 4, 0)
        when :instances
          Monitor::Panels::Instances.new((@height - 4), @width, 4, 0)
        when :help
          Monitor::Panels::Help.new((@height - 4), @width, 4, 0)
        end
      end

      private

      def term_height
        (ENV['LINES'] || Curses.lines).to_i
      end

      def term_width
        (ENV['COLUMNS'] || Curses.cols).to_i
      end

    end
  end
end
