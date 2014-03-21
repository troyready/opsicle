require 'opsicle/s3_bucket'
require 'zlib'
require 'archive/tar/minitar'

module Opsicle
  class ChefUpdate
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
      tar_cookbooks(options[:path])
      s3_upload(options[:"bucket-name"])
      cleanup_tar
      update_custom_cookbooks
      launch_stack_monitor(options)
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

    def launch_stack_monitor(options)
      Output.say_verbose "Starting Stack Monitor..."
      @monitor = Opsicle::Monitor::App.new(@environment, options)
      @monitor.start
    end
  end
end
