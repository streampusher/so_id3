require 'spec_helper'
require 'so_id3'

class Song < ActiveRecord::Base
  has_tags column: :mp3
end

describe SoId3 do
  before :all do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                            database: "spec/support/so_id3.sqlite3")
    load "spec/support/schema.rb"
  end
  describe "#has_tags" do
    context "with local files" do
      before :each do
        reset_tags
      end
      let(:song){ Song.create(mp3: 'spec/support/test.mp3') }
      it "fetches tags" do
        expect(song.artist).to eq('dj nameko')
        expect(song.title).to eq('a cool song')
      end
      it 'writes tags' do
        song.artist = 'dj heartrider'
        song.reload
        expect(song.artist).to eq('dj heartrider')
      end
    end
    context "with remote files" do
      before :each do
        reset_tags
        reset_s3_object
      end
      it 'works with remote files' do
        class SongWithS3 < ActiveRecord::Base
          has_tags column: :mp3, storage: :s3,
                   s3_credentials: { bucket: ENV['S3_BUCKET'],
                                     access_key_id: ENV['S3_KEY'],
                                     secret_access_key: ENV['S3_SECRET'] }
        end
        song_with_remote = SongWithS3.create(mp3: 'test.mp3')
        expect(song_with_remote.tags.artist).to eq('dj nameko')
        expect(song_with_remote.tags.title).to eq('a cool song')

        song_with_remote.tags.artist = 'dj heartrider'
        expect(song_with_remote.tags.artist).to eq('dj heartrider')
        song_with_remote.save!
        expect(song_with_remote.artist).to eq('dj heartrider')
      end
    end
  end
end
