require 'opsicle/s3_bucket'
require 'zlib'
require 'archive/tar/minitar'
require "opsicle/deploy_helper"

module Opsicle
  class ChefUpdate
    include DeployHelper
    attr_reader :client
    attr_reader :tar_file
    attr_reader :stack

    def initialize(environment)
      @environment = environment
      @client = Client.new(environment)
      @stack = Stack.new(@client)
      @tar_file = "#{@stack.name}.tgz"
    end

    def execute(options={ monitor: true })
      if options[:"bucket-name"]
        tar_cookbooks(options[:path])
        s3_upload(options[:"bucket-name"])
        cleanup_tar
      end
      response = update_custom_cookbooks
      launch_stack_monitor(response, options)
    end

    private

    def tar_cookbooks(cookbooks_dir)
      tgz = Zlib::GzipWriter.new(File.open(tar_file, 'wb'))
      package = Dir[cookbooks_dir].entries.reject{ |entry| entry =~ /^\.\.?$/ }
      Archive::Tar::Minitar.pack(package, tgz)
    end

    def s3_upload(bucket_name)
      bucket = S3Bucket.new(@client, bucket_name)
      bucket.update(tar_file)
    end

    def cleanup_tar
      FileUtils.rm(tar_file)
    end

    def update_custom_cookbooks
      Output.say "Starting OpsWorks Custom Cookboks Update..."
      client.run_command('update_custom_cookbooks')
    end
  end
end
