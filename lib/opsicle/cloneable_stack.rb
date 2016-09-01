module Opsicle
  class CloneableStack
    attr_accessor :id, :opsworks, :stack

    def initialize(stack_id, opsworks)
      self.id = stack_id
      self.opsworks = opsworks
      self.stack = get_stack
    end

    def get_stack
      @opsworks.describe_stacks({ :stack_ids => [self.id.to_s] }).stacks
    end
  end
end
