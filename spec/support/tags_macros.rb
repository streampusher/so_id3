module TagsMacros
  def reset_tags
    tags = {}
    tags[:artist] = 'dj nameko'
    tags[:title] = 'a cool song'
    mp3 = "spec/support/test.mp3"
    Rupeepeethree::Tagger.tag(mp3, tags)
  end

  def reset_s3_object
    mp3 = "spec/support/test.mp3"
    s3_credentials = { bucket: ENV['S3_BUCKET'],
                      access_key_id: ENV['S3_KEY'],
                      secret_access_key: ENV['S3_SECRET'] }
    @s3 = AWS::S3.new(access_key_id: s3_credentials[:access_key_id],
                      secret_access_key: s3_credentials[:secret_access_key])
    @bucket = @s3.buckets.create(s3_credentials[:bucket])
    key = File.basename(mp3)
    @bucket.objects[key].write(file: mp3, acl: :public_read)
  end
end
