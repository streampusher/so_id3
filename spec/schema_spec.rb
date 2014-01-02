require 'spec_helper'
require 'so_id3/schema'

describe SoId3::Schema do
  it 'creates the required columns' do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                            database: "spec/support/so_id3.sqlite3")
    class Song < ActiveRecord::Base; end

    ActiveRecord::Base.connection.create_table :songs, force: true do |t|
      t.string :mp3
      t.add_i3_tags :mp3
    end

    ["mp3_artist", "mp3_title", "mp3_album", "mp3_year", "mp3_track"].each do |t|
      expect(Song.column_names).to include(t)
    end
  end
end
