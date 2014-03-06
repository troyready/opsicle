Signal.trap("INT") do
  puts ""
  puts "Exiting..."
  exit 1
end

require "opsicle/helpers"
include Opsicle::Helpers

require "opsicle/version"
require "opsicle/commands"
require "opsicle/monitor"

