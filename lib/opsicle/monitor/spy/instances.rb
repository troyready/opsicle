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
              :ec2_instance_id => instance[:ec2_instance_id],
              :hostname => instance[:hostname],
              :status => instance[:status],
              :zone => instance[:availability_zone],
              :ip => Opsicle::Instances::pretty_ip(instance)
            }
          end

          h.sort! { |a,b| a[:hostname] <=> b[:hostname] }
          @data = h
        end

      end
    end
  end
end
