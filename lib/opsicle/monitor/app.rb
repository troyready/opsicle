# Credit where credit is due:
# The Monitor module's architecture and many of its classes are heavily based on
# the work of tiredpixel's sidekiq-spy gem: https://github.com/tiredpixel/sidekiq-spy
# His help in working with the Ruby curses library has been invaluable - thanks tiredpixel!

require 'opsicle/client'

module Opsicle
  module Monitor
    class App
      API_POLLING_INTERVAL = 10
      SCREEN_REFRESH_INTERVAL = 5

      attr_reader :running
      attr_reader :restarting
      attr_reader :deployment_id
      attr_reader :deploy

      class << self
        attr_accessor :client
      end

      def initialize(environment, options)
        @running       = false
        @restarting    = false
        @threads       = {}
        @deployment_id = options[:deployment_id]

        # Make client with correct configuration available to monitor spies
        App.client = Client.new(environment)
        @deploy = Opsicle::Deployment.new(@deployment_id, App.client) if @deployment_id
      end

      def start
        begin
          @running = true

          setup

          @threads[:command] ||= Thread.new do
            command_loop # listen for commands
          end

          @threads[:refresh_screen] ||= Thread.new do
            refresh_screen_loop # refresh frequently
          end

          @threads[:refresh_data] ||= Thread.new do
            refresh_data_loop # refresh not so frequently
          end

          if @deploy
            @threads[:check_status] ||= Thread.new do
              refresh_deploy_status_loop # refresh not so frequently
            end
          end

          @threads.each { |tname, t| t.join }
        ensure
          cleanup
        end
      end

      def stop(error=nil)
        @running = false
        @screen.close
        @screen = nil # Ruby curses lib doesn't have closed?(), so we set to nil, just in case

        raise (error || QuitMonitor)
      end

      def restart
        @restarting = true
      end

      def do_command(key)
        command = { 'q' => :stop,
                    'h' => [:set_screen, :help],
                    'b' => :open_opsworks_browser,
                    'd' => [:set_screen, :deployments],
                    'i' => [:set_screen, :instances], }[key]
        command ||= :invalid_input

        send *command unless command == :invalid_input

        wakey_wakey # wake threads for immediate response
      end

      private

      def set_screen(screen)
        @screen.panel_main = screen
      end

      def setup
        @screen = Monitor::Screen.new
      end

      def cleanup
        @screen.close if @screen
      end

      def wakey_wakey
        @threads.each { |tname, t| t.run if t.status == 'sleep' }
      end

      def command_loop
        while @running do
          next unless @screen # #refresh_loop might be reattaching screen

          key = @screen.next_key

          next unless key # keep listening if timeout

          do_command(key)
        end
      end

      def refresh_screen_loop
        while @running do
          next unless @screen # HACK: only certain test scenarios?

          if @restarting || @screen.missized? # signal(s) or whilst still resizing
            panel_main = @screen.panel_main

            cleanup

            setup

            @screen.panel_main = panel_main

            @restarting = false
          end

          @screen.refresh

          sleep SCREEN_REFRESH_INTERVAL # go to sleep; could be rudely awoken on quit
        end
      end

      # This loop is specifically separate from the screen loop
      # because we don't want to spam OpWorks with API calls every second.
      def refresh_data_loop
        while @running do
          next unless @screen # HACK: only certain test scenarios?

          @screen.refresh_spies

          sleep API_POLLING_INTERVAL
        end
      end

      # This is an optional loop that is meant for keeping track of a deploy
      # and exiting on compltion.  It uses it's own API call since digging down
      # to the spies would get ugly.
      def refresh_deploy_status_loop
        while @running do
          next unless @screen # HACK: only certain test scenarios?

          check_deploy_status

          sleep API_POLLING_INTERVAL
        end
      end

      def check_deploy_status
        unless deploy_running?
          deploy.deployment.failed? ? stop(DeployFailed) : stop
        end
      end

      def deploy_running?
        deploy.deployment(:reload => true).running?
      end

      def open_opsworks_browser
        %x(open 'https://console.aws.amazon.com/opsworks/home?#/stack/#{App.client.config.opsworks_config[:stack_id]}')
      end
    end

    QuitMonitor  = Class.new(StandardError)
    DeployFailed = Class.new(StandardError)
  end
end
