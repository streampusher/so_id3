ActiveRecord::Schema.define do
  self.verbose = false

  create_table :songs, force: true do |t|
    t.string :mp3

    t.timestamps
  end
end
