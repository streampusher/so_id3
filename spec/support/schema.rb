ActiveRecord::Schema.define do
  self.verbose = false

  create_table :songs, force: true do |t|
    t.string :mp3
    t.i3_tags

    t.timestamps
  end

  create_table :song_with_s3s, force: true do |t|
    t.string :mp3
    t.i3_tags

    t.timestamps
  end
end
