require "json"
require "opsicle/user_profile"

module Opsicle
  class UserProfileInfo
    attr_reader :client

    def initialize(environment)
      @client = Client.new(environment)
      @user_profile = UserProfile.new(@client)
    end

    def execute(options={})
      Output.say output.to_json
    end

    def output
      @user_profile.attributes
    end
  end
end
