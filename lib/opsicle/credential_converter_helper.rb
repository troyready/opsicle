require 'yaml'

module Opsicle
  module CredentialConverterHelper
    def convert_fog_to_aws
      # open/make new credentials file, read, and gather the groups of aws credentials already in file
      cred_path = File.expand_path("~/.aws/credentials")
      cred_file = File.open(cred_path, "a+")
      cred_text = cred_file.read
      cred_groups = cred_text.scan(/\[([a-z]*)\]/).flatten

      # open existing fog file, and load as yaml hash
      fog_path = File.expand_path("~/.fog")
      fog_hash = YAML::load_file(fog_path)

      # for each environment in the fog file, go through and if it isn't in credentials file, then put it and data in
      fog_hash.each do | environment, credentials |
        if !cred_groups.include?(environment)
          copy_data(cred_file, environment, credentials)
        end
      end

      # close to save, reopen new credentials file, get rid of extra newlines at beginning, put edited text back into
      # cred_file, and close
      cred_file.close
      cred_file = File.open(cred_path, "a+")
      cred_text = cred_file.read
      cred_text = cred_text.strip
      cred_text << "\n"
      cred_file = cred_file.reopen(cred_path, "w")
      cred_file.puts cred_text
      cred_file.close
    end

    def copy_data(cred_file, environment, credentials)
      cred_file.puts
      cred_file.puts "[#{environment}]"
      credentials.each do | key, value |
        cred_file.puts "#{key} = #{value}"
      end
    end
  end
end
