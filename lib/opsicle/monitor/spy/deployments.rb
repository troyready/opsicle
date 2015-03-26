require 'opsicle/deployments'

module Opsicle
  module Monitor
    module Spy
      class Deployments

        include Spy::Dataspyable

        def initialize
          @deployments = Opsicle::Deployments.new(Opsicle::Monitor::App.client)
          refresh
        end

        def refresh
          h = []

          @deployments.data.each do |deployment|
            # Massage the API data for our uses
            h << {
              :deployment_id => deployment[:deployment_id],
              :stack_id      => deployment[:stack_id],
              :app_id        => deployment[:app_id],
              :created_at    => format_date(deployment[:created_at]),
              :completed_at  => format_date(deployment[:completed_at]),
              :duration      => deployment[:duration],
              :user          => user_from_arn(deployment[:iam_user_arn]),
              :comment       => deployment[:comment],
              :command       => deployment[:command][:name],
              :command_args  => deployment[:command][:args],
              :name          => deployment[:name],
              :args          => deployment[:args],
              :value         => deployment[:value],
              :status        => deployment[:status],
              :custom_json   => deployment[:custom_json],
              :instance_ids  => deployment[:instance_ids]
            }
          end

          @data = h
        end

        def user_from_arn(amazon_resource_name)
          /(?::user\/)?([^:\n]+)$/.match(amazon_resource_name).to_a[1].to_s
        end

        def format_date(date)
          date ? Time.parse(date).strftime("%T %m/%d") : ""
        end

      end
    end
  end
end
