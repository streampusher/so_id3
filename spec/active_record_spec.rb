require 'spec_helper'
require 'so_id3/active_record'

describe SoId3::ActiveRecord do
  describe "#has_tags" do
    it "fetches tags" do
      ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                              database: "spec/support/so_id3.sqlite3")
      load "spec/support/schema.rb"
      class Song < ActiveRecord::Base
        has_tags column: :mp3
      end
      song = Song.create(mp3: 'spec/support/test.mp3')

      expect(song.tags[:artist]).to eq('dj nameko')
      expect(song.tags[:title]).to eq('a cool song')
    end
  end
end
