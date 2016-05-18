module Opsicle
  class CredentialConverterHelper
    def convert_fog_to_aws
      # open/make new credentials file, read, and gather the groups of aws credentials already in file
      cred_path = File.expand_path("~/.aws/credentials")
      cred_file = File.open(cred_path, "a+")
      cred_text = cred_file.read
      cred_groups = cred_text.scan(/\[([a-z]*)\]/).flatten

      # open existing fog file, read, and gather groups of aws credentials in fog file
      fog_path = File.expand_path("~/.fog")
      fog_file = File.open(fog_path, "a+")
      fog_text = fog_file.read
      fog_text << "\n" # put extra new line on file for regex to work
      fog_groups = fog_text.scan(/\n([a-z]*)\:\n/).flatten

      # groups of credentials in fog file that are not in credentials file
      groups_to_transfer = fog_groups - cred_groups

      # for each credential to transfer, go through and put credentials group name and the credentials into new file
      groups_to_transfer.each do | group_name |
        cred_file.puts
        cred_file.puts "[#{group_name}]"
        text_to_add = fog_text.scan(/#{group_name}:\n((.+\n)*)/).flatten.first
        cred_file.puts text_to_add
      end

      # close everything to save
      cred_file.close
      fog_file.close

      # reopen new credentials file, get rid of extra newlines at beginning and end, get rid of whitespace, and turn ": " into " = "
      cred_file = File.open(cred_path, "a+")
      cred_text = cred_file.read
      cred_text = cred_text.strip
      cred_text = cred_text.gsub(/\n\s{2,}/, "\n")
      cred_text = cred_text.gsub(/:\s/, " = ")

      # append extra new line at end, and put new edited text back into cred file before closing again
      cred_text << "\n"
      cred_file = cred_file.reopen(cred_path, "w")
      cred_file.puts cred_text
      cred_file.close
    end
  end
end
