require "spec_helper"
require "opsicle"

module Opsicle
  describe  S3Bucket do
    before do
      @object = double('object', :upload_file => true)
      @bucket = double('bucket', :exists? => true, :object => @object)
      allow(Aws::S3::Bucket).to receive(:new).and_return(@bucket)
      @bucket_name = 'name'
      @client = double('client', :s3 => true)
      allow(Pathname).to receive(:new)
    end

    context "#new" do
      it "find the bucket from s3" do
        expect(@client).to receive(:s3)
        expect(@bucket).to receive(:exists?)
        expect(Aws::S3::Bucket).to receive(:new)
        S3Bucket.new(@client, @bucket_name)
      end

      it "throws an error if the bucket can't be found" do
        allow(@bucket).to receive(:exists?).and_return(false)
        expect { S3Bucket.new(@client, @bucket_name) }.to raise_error(UnknownBucket)
      end
    end

    context "#update" do
      it "finds the object in the s3 bucket" do
        expect(@bucket).to receive(:object)
        bucket = S3Bucket.new(@client, @bucket_name)
        bucket.update("object")
      end

      it "writes the new object in the s3 bucket" do
        expect(Pathname).to receive(:new).with("object")
        expect(@object).to receive(:upload_file)
        allow(@bucket).to receive(:object).and_return(@object)
        bucket = S3Bucket.new(@client, @bucket_name)
        bucket.update("object")
      end
    end
  end
end
