require 'spec_helper'
require 'so_id3'

describe SoId3 do
  before :all do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                            database: "spec/support/so_id3.sqlite3")
    load "spec/support/schema.rb"
  end
  describe "#has_tags" do
    class Song < ActiveRecord::Base
      include SoId3::BackgroundJobs
      include GlobalID::Identification
      GlobalID.app="soid3-test"
      has_tags column: :mp3
    end
    context "with local files" do
      before :each do
        reset_tags
        @song = Song.create(mp3: 'spec/support/test.mp3')
        @song.reload
      end
      it "fetches tags from the file to the db" do
        expect(@song.artist).to eq('dj nameko')
        expect(@song.title).to eq('a cool song')
      end
      it 'writes tags from the db to the file' do
        @song.artist = 'dj heartrider'
        @song.save
        @song.reload
        expect(Rupeepeethree::Tagger.tags(@song.mp3).fetch(:artist)).to eq('dj heartrider')
      end
      it 'works with a hash of attributes' do
        @song.attributes = { artist: 'dj heartrider', title: 'a cooler song', album: "hey" }
        @song.save
        expect(Rupeepeethree::Tagger.tags(@song.mp3).fetch(:artist)).to eq('dj heartrider')
        expect(Rupeepeethree::Tagger.tags(@song.mp3).fetch(:title)).to eq('a cooler song')
        expect(Rupeepeethree::Tagger.tags(@song.mp3).fetch(:album)).to eq('hey')
      end
    end
    context "with remote files" do
      it 'works with remote files' do
        class SongWithS3 < ActiveRecord::Base
          has_tags column: :mp3, storage: :s3,
                   s3_credentials: { bucket: ENV['S3_BUCKET'],
                                     access_key_id: ENV['S3_KEY'],
                                     secret_access_key: ENV['S3_SECRET'] }
          include SoId3::BackgroundJobs
          include GlobalID::Identification
          GlobalID.app="soid3-test"
        end
        VCR.use_cassette "song_with_remote" do
          reset_tags
          reset_s3_object
          song_with_remote = SongWithS3.create(mp3: 'test.mp3')
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj nameko')
          expect(song_with_remote.title).to eq('a cool song')

          song_with_remote.artist = 'dj heartrider'
          song_with_remote.save!
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj heartrider')
        end
      end
    end
  end
end
