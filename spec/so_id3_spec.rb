require 'spec_helper'
require 'so_id3'

describe SoId3 do
  let(:song){ Song.create(mp3: 'spec/support/test.mp3') }
  before :all do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                            database: "spec/support/so_id3.sqlite3")
    load "spec/support/schema.rb"
    class Song < ActiveRecord::Base
      has_tags column: :mp3
    end

  end
  before :each do
    reset_tags
  end
  describe "#has_tags" do
    it "fetches tags" do
      expect(song.tags.artist).to eq('dj nameko')
      expect(song.tags.title).to eq('a cool song')
    end
    it 'writes tags' do
      song.tags.artist = 'dj heartrider'
      expect(song.tags.artist).to eq('dj heartrider')
    end
    it 'works with remote files' do
      class SongWithS3 < ActiveRecord::Base
        has_tags column: :mp3, storage: :s3,
                 s3_credentials: { bucket: ENV['S3_BUCKET'],
                                   access_key_id: ENV['S3_KEY'],
                                   secret_access_key: ENV['S3_SECRET'] }
      end
      song_with_remote = SongWithS3.create(mp3: 'https://s3.amazonaws.com/datafruits.fm/test.mp3')
      expect(song_with_remote.tags.artist).to eq('dj nameko')
      expect(song_with_remote.tags.title).to eq('a cool song')
      song.tags.artist = 'dj heartrider'

      # create another record to download the file again, to check that the tags were actually written
      download_again_to_test = SongWithS3.create(mp3: 'https://s3.amazonaws.com/datafruits.fm/test.mp3')
      expect(download_again_to_test.tags.artist).to eq('dj heartrider')
    end
  end
end
