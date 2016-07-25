require 'spec_helper'
require 'active_job'
require 'so_id3'
require 'paperclip'

describe SoId3 do
  before :all do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                            database: "spec/support/so_id3.sqlite3")
    load "spec/support/schema.rb"
    ActiveRecord::Base.raise_in_transactional_callbacks = true
    ActiveJob::Base.queue_adapter = :inline
  end
  describe "#has_tags" do
    class SongWithS3 < ActiveRecord::Base
      include SoId3::BackgroundJobs
      include GlobalID::Identification
      GlobalID.app="soid3-test"

      include Paperclip::Glue
      has_attached_file :artwork,
        storage: :filesystem,
        path: "tmp/:attachment/:id/:style/:basename.:extension"
      validates_attachment_content_type :artwork, content_type: /\Aimage\/.*\Z/

      has_tags column: :mp3, storage: :s3, artwork_column: :artwork,
               s3_credentials: { bucket: ENV['S3_BUCKET'],
                                 access_key_id: ENV['S3_KEY'],
                                 secret_access_key: ENV['S3_SECRET'] }

      def mp3_url
        "https://s3.amazonaws.com/#{ENV['S3_BUCKET']}/#{mp3}"
      end
    end
    context "with remote files" do
      it 'works with remote files' do
        VCR.use_cassette "song_with_remote" do
          reset_tags
          reset_s3_object
          song_with_remote = SongWithS3.create(mp3: 'test.mp3')
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj nameko')
          expect(song_with_remote.title).to eq('a cool song')
          expect(File.read(song_with_remote.artwork.path)).to eq File.read("spec/support/artwork.png")

          song_with_remote.artist = 'dj heartrider'
          song_with_remote.save!
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj heartrider')
          downloaded_mp3 = download_mp3_tempfile song_with_remote.mp3_url
          expect(Rupeepeethree::Tagger.tags(downloaded_mp3.path).fetch(:artist)).to eq('dj heartrider')
        end
      end
      it "works with files in subdirectories on s3" do
        class SongWithS3 < ActiveRecord::Base
          has_tags column: :mp3, storage: :s3,
                   s3_credentials: { bucket: ENV['S3_BUCKET'],
                                     access_key_id: ENV['S3_KEY'],
                                     secret_access_key: ENV['S3_SECRET'] }
          include SoId3::BackgroundJobs
          include GlobalID::Identification
          GlobalID.app="soid3-test"

          def mp3_url
            "https://s3.amazonaws.com/#{ENV['S3_BUCKET']}/#{mp3}"
          end
        end
        reset_tags
        reset_s3_object_in_subdir
        VCR.use_cassette "song_with_remote_in_subdirectory" do
          song_with_remote = SongWithS3.create(mp3: 'subdir/test.mp3')
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj nameko')
          expect(song_with_remote.title).to eq('a cool song')
          expect(File.read(song_with_remote.artwork.path)).to eq File.read("spec/support/artwork.png")

          song_with_remote.artist = 'dj heartrider'
          song_with_remote.save!
          song_with_remote.reload

          expect(song_with_remote.artist).to eq('dj heartrider')
          downloaded_mp3 = download_mp3_tempfile song_with_remote.mp3_url
          expect(Rupeepeethree::Tagger.tags(downloaded_mp3.path).fetch(:artist)).to eq('dj heartrider')

          song_with_remote.artist = 'dj dingus'
          song_with_remote.save!
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj dingus')
          downloaded_mp3 = download_mp3_tempfile song_with_remote.mp3_url
          expect(Rupeepeethree::Tagger.tags(downloaded_mp3.path).fetch(:artist)).to eq('dj dingus')
        end
      end
      it "handles filenames with escaped characters" do
        class SongWithS3 < ActiveRecord::Base
          has_tags column: :mp3, storage: :s3,
                   s3_credentials: { bucket: ENV['S3_BUCKET'],
                                     access_key_id: ENV['S3_KEY'],
                                     secret_access_key: ENV['S3_SECRET'] }
          include SoId3::BackgroundJobs
          include GlobalID::Identification
          GlobalID.app="soid3-test"

          def mp3_url
            "https://s3.amazonaws.com/#{ENV['S3_BUCKET']}/#{mp3}"
          end
        end
        VCR.use_cassette "song_with_remote_with_special_characters" do
          reset_tags
          reset_s3_object "spec/support/the cowbell wau with spaces.mp3"
          song_with_remote = SongWithS3.create(mp3: 'the cowbell wau with spaces.mp3')
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj nameko')
          expect(song_with_remote.title).to eq('a cool song')

          song_with_remote.artist = 'dj heartrider'
          song_with_remote.save!
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj heartrider')
          downloaded_mp3 = download_mp3_tempfile song_with_remote.mp3_url
          expect(Rupeepeethree::Tagger.tags(downloaded_mp3.path).fetch(:artist)).to eq('dj heartrider')

          song_with_remote.artist = 'dj dingus'
          song_with_remote.save!
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj dingus')
          downloaded_mp3 = download_mp3_tempfile song_with_remote.mp3_url
          expect(Rupeepeethree::Tagger.tags(downloaded_mp3.path).fetch(:artist)).to eq('dj dingus')
        end
      end
    end
  end
end
