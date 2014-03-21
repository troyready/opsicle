require 'opsicle/instances'

module Opsicle
  module Monitor
    module Spy
      class Instances

        include Spy::Dataspyable

        def initialize
          @instances = Opsicle::Instances.new(Opsicle::Monitor::App.client)
          refresh
        end

        def refresh
          h = []

          @instances.data.each do |instance|
            # Massage the API data for our uses
            h << {
              :hostname => instance[:hostname],
              :status => instance[:status],
              :zone => instance[:availability_zone],
              :ip => instance[:elastic_ip] || instance[:public_ip]
            }
          end

          @data = h
        end

      end
    end
  end
end
