require 'open-uri'
require "addressable/uri"

module TagsMacros
  def reset_tags
    tags = {}
    tags[:artist] = 'dj nameko'
    tags[:title] = 'a cool song'
    tags[:picture] = "spec/support/artwork.png"
    mp3 = "spec/support/test.mp3"
    Rupeepeethree::Tagger.tag(mp3, tags)
  end

  def reset_s3_object mp3 = "spec/support/test.mp3"
    s3_credentials = { bucket: ENV['S3_BUCKET'],
                      access_key_id: ENV['S3_KEY'],
                      secret_access_key: ENV['S3_SECRET'],
                      region: ENV['S3_REGION'] }
    VCR.use_cassette "reset_s3_object_#{File.basename(mp3)}", preserve_exact_body_bytes: true do
      @s3 = Aws::S3::Client.new(access_key_id: s3_credentials[:access_key_id],
                        secret_access_key: s3_credentials[:secret_access_key], region: s3_credentials[:region])
      @s3.create_bucket(bucket: s3_credentials[:bucket])
      key = File.basename(mp3)
      @s3.put_object(bucket: s3_credentials[:bucket], key: key, body: File.open(mp3), acl: "public-read", content_type: "audio/mpeg")
    end
  end

  def reset_s3_object_in_subdir mp3 = "spec/support/test.mp3"
    s3_credentials = { bucket: ENV['S3_BUCKET'],
                      access_key_id: ENV['S3_KEY'],
                      secret_access_key: ENV['S3_SECRET'],
                      region: ENV['S3_REGION'] }
    VCR.use_cassette "reset_s3_object_in_subdir_#{File.basename(mp3)}", preserve_exact_body_bytes: true do
      @s3 = Aws::S3::Client.new(access_key_id: s3_credentials[:access_key_id],
                        secret_access_key: s3_credentials[:secret_access_key], region: s3_credentials[:region])
      @s3.create_bucket(bucket: s3_credentials[:bucket])
      key = "subdir/test.mp3"
      @s3.put_object(bucket: s3_credentials[:bucket], key: key, body: File.open(mp3), acl: "public-read", content_type: "audio/mpeg")
    end
  end

  def download_mp3_tempfile url
    t = Tempfile.new
    t.binmode
    URI.open(Addressable::URI.encode(url), "rb") do |read_file|
      t.write(read_file.read)
    end
    t
  end
end
