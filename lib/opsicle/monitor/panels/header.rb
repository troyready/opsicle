require 'time'
require 'opsicle/monitor/panel'
require 'opsicle/stack'

module Opsicle
  module Monitor
    module Panels
      class Header < Opsicle::Monitor::Panel

        attr_accessor :panel_main

        def initialize(height, width, top, left)
          @stack = Opsicle::Stack.new(App.client)

          super(height, width, top, left, structure, :divider_r => " ")
        end

        def structure
          @panel_main = nil # set by Display::Screen#main_panel=

          # [
          #   [relative_column_width, data_left, data_right]
          # ]
          [
            [
              [2, translate[:program], nil],
              [2, -> {
                [:deployments, :instances, :help].map do |e|
                  translate[:menu][(e == @panel_main ? :active : :inactive)][e]
                end.join("  ")
              }, nil],
              [1, nil, -> { Time.now.strftime("%T %z") }],
            ],
            [
              [1, nil, nil],
            ],
            [
              [1, "Stack name:", @stack.name],
              [1, nil, nil],
              [1, nil, nil]
            ]
          ]
        end

      end
    end
  end
end
