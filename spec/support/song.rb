class Song < ActiveRecord::Base
  include SoId3::BackgroundJobs
  include GlobalID::Identification
  GlobalID.app="soid3-test"

  include Paperclip::Glue
  has_attached_file :artwork,
    storage: :filesystem,
    path: "tmp/:attachment/:id/:style/:basename.:extension"
  validates_attachment_content_type :artwork, content_type: /\Aimage\/.*\Z/

  enum tag_processing_status: ['unprocessed', 'processing', 'done', 'failed']
  has_tags column: :mp3, artwork_column: :artwork
end
