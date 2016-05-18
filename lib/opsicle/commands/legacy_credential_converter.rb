require "opsicle/credential_converter_helper"

module Opsicle
  class LegacyCredentialConverter
    include CredentialConverterHelper

    def initialize(environment)
      @environment = environment
    end

    def execute(options={ monitor: true })
      Output.say "Converting your ~/.fog file to a ~/.aws/credentials file..."

      convert_fog_to_aws
    end
  end
end
