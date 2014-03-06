module Opsicle
  class SSHKey

    def initialize(environment, keyfile)
      @client = Client.new(environment)
      @keyfile = keyfile
    end

    def execute(options={})
      validate!
      update
      tell "ssh-key updated successfully"
    end

    def validate!
      raise KeyFileNotFound, "No key file could be found" unless File.exists?(@keyfile)
      raise InvalidKeyFile, "Key file is invalid" unless valid_key_file?
      raise InvalidKeyFile, "Key file is a private key" unless public_key?
    end

    def valid_key_file?
      system("ssh-keygen -l -f #{@keyfile} > /dev/null")
    end

    def public_key?
      !key.match(/PRIVATE KEY/)
    end

    def key
      @key ||= File.read(@keyfile)
    end

    def update
      @client.api_call(:update_my_user_profile, {ssh_public_key: key})
    end

  end
  KeyFileNotFound = Class.new(StandardError)
  InvalidKeyFile = Class.new(StandardError)
end
