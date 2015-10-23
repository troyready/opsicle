# ls -1rt /var/lib/aws/opsworks/chef/*.log |tail -n 1

module Opsicle
  module Monitor
    module Panels
      class Logs < Monitor::Panel

        def initialize(height, width, top, left)
          super(height, width, top, left, structure(height), :divider_r => " ")

          @spies[:instances] = Monitor::Spy::Instances.new
        end

        def structure(height)
          # [
          #   [relative_column_width, data_left, data_right]
          # ]
          s = [
              [ # table header slots
                  [1, translate[:heading][:ec2_instance_id], nil],
                  [1, translate[:heading][:hostname], nil],
                  [1, translate[:heading][:status], nil],
                  [1, translate[:heading][:zone], nil],
                  [1, translate[:heading][:ip], nil]
              ],
          ]

          (0...(height - 1)).each do |i|
            s << [ # table row slots
                [1, -> { @spies[:instances][i][:ec2_instance_id] }, nil],
                [1, -> { @spies[:instances][i][:hostname] }, nil],
                [1, -> { @spies[:instances][i][:status] }, nil],
                [1, -> { @spies[:instances][i][:zone] }, nil],
                [1, -> { @spies[:instances][i][:ip] }, nil]
            ]
          end

          s
        end

      end
    end
  end
end
