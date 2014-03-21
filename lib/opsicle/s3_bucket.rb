require 'pathname'

module Opsicle
  class S3Bucket
     attr_reader :bucket

     def initialize(client, bucket_name)
        @bucket = client.s3.buckets[bucket_name]
        raise UnknownBucket unless @bucket.exists?
     end

     def update(object)
       obj = bucket.objects[object]
       obj.write(Pathname.new(object))
     end
  end

  UnknownBucket = Class.new(StandardError)
end
