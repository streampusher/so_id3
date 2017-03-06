class SongWithS3 < ActiveRecord::Base
  include SoId3::BackgroundJobs
  include GlobalID::Identification
  GlobalID.app="soid3-test"

  include Paperclip::Glue
  has_attached_file :artwork,
    storage: :s3,
    s3_credentials: Proc.new{|a| a.instance.s3_credentials },
    path: ":attachment/:style/:basename.:extension"

  validates_attachment_content_type :artwork, content_type: /\Aimage\/.*\Z/

  has_tags column: :mp3, storage: :s3, artwork_column: :artwork,
           s3_credentials: { bucket: ENV['S3_BUCKET'],
                             access_key_id: ENV['S3_KEY'],
                             secret_access_key: ENV['S3_SECRET'],
                             region: ENV['S3_REGION'] }

  def s3_credentials
    { bucket: ENV['S3_BUCKET'], access_key_id: ENV['S3_KEY'], secret_access_key: ENV['S3_SECRET'], s3_region: ENV['S3_REGION'], region: ENV['S3_REGION'] }
  end

  def mp3_url
    "https://s3.amazonaws.com/#{ENV['S3_BUCKET']}/#{mp3}"
  end
end
