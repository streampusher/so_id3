ActiveRecord::Schema.define do
  self.verbose = false

  create_table :songs, force: true do |t|
    t.string :mp3
    t.id3_tags
    t.integer :tag_processing_status, null: false, default: 0
    t.string :another_column

    t.string :artwork_file_name
    t.integer :artwork_file_size
    t.string :artwork_content_type
    t.datetime :artwork_update_at
    t.timestamps null: true
  end

  create_table :song_with_s3s, force: true do |t|
    t.string :mp3
    t.id3_tags
    t.integer :tag_processing_status, null: false, default: 0

    t.string :artwork_file_name
    t.integer :artwork_file_size
    t.string :artwork_content_type
    t.datetime :artwork_update_at
    t.timestamps null: true
  end
end
