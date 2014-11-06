require "spec_helper"
require "opsicle"
require 'archive/tar/minitar'

module Opsicle
  describe  ChefUpdate do
    subject { ChefUpdate.new('derp') }
    let(:monitor) { double(:start => nil) }
    let(:client) { double }
    let(:stack) { double(name: 'stack')  }
    let(:tar_file) { "stack.tgz" }
    let(:bucket_name) { "cookbooks" }
    let(:bucket) { double }
    let(:cookbooks_dirname) { "cookbooks" }

    before do
      allow(Client).to receive(:new).with('derp').and_return(client)
      allow(Stack).to receive(:new).with(client).and_return(stack)
      allow(subject).to receive(:tar_file).and_return(tar_file)

      allow(Monitor::App).to receive(:new).and_return(monitor)
      allow(monitor).to receive(:start)

      allow(Output).to receive(:say)
      allow(Output).to receive(:say_verbose)
    end

    context "#execute" do
      context "s3 upload" do

        it "tars up the cookooks" do
          allow(subject).to receive(:s3_upload)
          allow(subject).to receive(:cleanup_tar)
          allow(subject).to receive(:update_custom_cookbooks)
          allow(subject).to receive(:launch_stack_monitor)
          expect(subject).to receive(:tar_cookbooks)

          subject.execute(:"bucket-name" => bucket_name)
        end

        it "uploads the cookbooks to s3" do
          allow(subject).to receive(:tar_cookbooks)
          allow(subject).to receive(:cleanup_tar)
          allow(subject).to receive(:update_custom_cookbooks)
          allow(subject).to receive(:launch_stack_monitor)
          expect(subject).to receive(:s3_upload)

          subject.execute(:"bucket-name" => bucket_name)
        end

        it "cleans up the tarball created to upload to s3" do
          allow(subject).to receive(:tar_cookbooks)
          allow(subject).to receive(:s3_upload)
          allow(subject).to receive(:update_custom_cookbooks)
          allow(subject).to receive(:launch_stack_monitor)
          expect(subject).to receive(:cleanup_tar)

          subject.execute(:"bucket-name" => bucket_name)
        end
      end

      it "creates a new update_custom_cookbooks and opens stack monitor" do
        allow(subject).to receive(:tar_cookbooks)
        allow(subject).to receive(:s3_upload)
        allow(subject).to receive(:cleanup_tar)
        allow(subject).to receive(:launch_stack_monitor)
        expect(subject).to receive(:update_custom_cookbooks)

        subject.execute
      end

      it "starts the stack monitor" do
        allow(subject).to receive(:tar_cookbooks)
        allow(subject).to receive(:s3_upload)
        allow(subject).to receive(:cleanup_tar)
        allow(subject).to receive(:update_custom_cookbooks)
        expect(subject).to receive(:launch_stack_monitor)

        subject.execute
      end

      it "can exit on completion" do
        allow(subject).to receive(:tar_cookbooks)
        allow(subject).to receive(:s3_upload)
        allow(subject).to receive(:cleanup_tar)
        allow(subject).to receive(:update_custom_cookbooks).and_return({:deployment_id => 123})
        expect(Monitor::App).to receive(:new).with('derp', :monitor => true, :deployment_id => 123)

        subject.execute({:monitor => true, :track => true})
      end
    end

    context "#tar_cookbooks" do
      let(:tar_file_handle) { double }
      let(:cookbooks_dir) { double }
      let(:gzip) { double }
      let(:entries) { %w(recipes templates files) }
      it "tarballs up the cookbooks directory" do
        expect(File).to receive(:open).with(tar_file, 'wb').and_return(tar_file_handle)
        expect(Zlib::GzipWriter).to receive(:new).with(tar_file_handle).and_return(gzip)
        expect(Dir).to receive(:"[]").with(cookbooks_dirname).and_return(cookbooks_dir)
        expect(cookbooks_dir).to receive(:entries).and_return(entries)
        expect(Archive::Tar::Minitar).to receive(:pack).with(entries, gzip)
        subject.send :tar_cookbooks, cookbooks_dirname
      end
    end

    context "#s3_upload" do
      it "updates the s3 bucket with the tarballed cookbooks" do
        expect(S3Bucket).to receive(:new).with(client, bucket_name).and_return(bucket)
        expect(bucket).to receive(:update).with(tar_file)
        subject.send :s3_upload, bucket_name
      end
    end

    context "#cleanup_tar" do
      it "removes the tar file now that the upload is complete" do
        expect(FileUtils).to receive(:rm).with(tar_file)
        subject.send :cleanup_tar
      end
    end

    context "#update_custom_cookbooks" do
      it "runs the aws update custom cookbooks command" do
        expect(client).to receive(:run_command).with('update_custom_cookbooks')

        subject.send :update_custom_cookbooks
      end
    end

    context "#launch_stack_monitor" do
      let(:options) { { derp: 'herp', monitor: true } }
      it "launches the opsicle stack monitor" do

        expect(Monitor::App).to receive(:new).with('derp', options)

        subject.send :launch_stack_monitor, nil, options
      end
    end
  end
end
