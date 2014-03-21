require "spec_helper"
require "opsicle"

module Opsicle
  describe  S3Bucket do
    subject { S3Bucket.new(client, bucket_name) }
    let(:bucket_name) { "bucket" }
    let(:bucket) { double(exists?: true) }
    let(:buckets) { double(:"[]" => bucket) }
    let(:s3) { double(buckets: buckets) }
    let(:client) { double(s3: s3) }

    context "#new" do
      subject { S3Bucket }
      it "finds the bucket from s3" do
        expect(client).to receive(:s3).and_return(s3)
        expect(s3).to receive(:buckets).and_return(buckets)
        expect(buckets).to receive(:"[]").with(bucket_name).and_return(bucket)
        subject.new(client, bucket_name)
      end

      it "throws an error if the bucket can't be found" do
        allow(bucket).to receive(:exists?).and_return(false)
        expect(client).to receive(:s3).and_return(s3)
        expect(s3).to receive(:buckets).and_return(buckets)
        expect(buckets).to receive(:"[]").with(bucket_name).and_return(bucket)
        expect { subject.new(client, bucket_name) }.to raise_error(UnknownBucket)
      end
    end

    context "#update" do
      let(:object) { double }
      let(:objects) { double(:"[]" => object) }
      before do
        allow(Pathname).to receive(:new)
      end

      it "finds the object in the s3 bucket" do
        allow(object).to receive(:write)
        expect(bucket).to receive(:objects).and_return(objects)
        subject.update(object)
      end

      it "writes the new object in the s3 bucket" do
        allow(bucket).to receive(:objects).and_return(objects)
        expect(object).to receive(:write)
        subject.update(object)
      end
    end
  end
end
