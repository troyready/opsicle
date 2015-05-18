module Opsicle
  class UserProfile
    attr_reader :client

    def initialize(client)
      @client = client
    end

    def ssh_username
      attributes.fetch(:ssh_username)
    end

    def iam_username
      attributes.fetch(:name)
    end

    def public_key
      attributes.fetch(:ssh_public_key)
    end

    def arn
      attributes.fetch(:iam_user_arn)
    end

    def attributes
      @attributes ||= client.api_call(:describe_my_user_profile)[:user_profile]
    end

  end
end
