module Opsicle
  module Monitor
    module Panels
      class Help < Monitor::Panel

        def initialize(height, width, top, left)
          super(height, width, top, left, structure(height), :divider_r => " ")
        end

        def structure(height)
          # [
          #   [relative_column_width, data_left, data_right]
          # ]
          s = [
            [
              [1, "'h' : Show this help screen", nil],
            ],
            [
              [1, "'d' : Show deployment list on this OpsWorks stack", nil],
            ],
            [
              [1, "'i' : Show instance list on this OpsWorks stack", nil],
            ],
            [
              [1, "'b' : Open OpsWorks screen for this stack in your browser", nil],
            ],
            [
              [1, "'q' : Quit", nil],
            ]
          ]
        end

      end
    end
  end
end
