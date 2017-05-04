require 'spec_helper'

describe SoId3 do
  before :all do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                            database: "spec/support/so_id3.sqlite3")
    load "spec/support/schema.rb"
    ActiveJob::Base.queue_adapter = :inline
  end
  describe "#has_tags" do
    context "with remote files" do
      it 'works with remote files' do
        VCR.use_cassette "song_with_remote" do
          reset_tags
          reset_s3_object
          song_with_remote = SongWithS3.create(mp3: 'test.mp3')
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj nameko')
          expect(song_with_remote.title).to eq('a cool song')

          uri = URI.parse(song_with_remote.artwork.url)
          t = Tempfile.new([File.basename(song_with_remote.artwork.path, ".*"), File.extname(song_with_remote.artwork.path)])
          t.binmode
          Net::HTTP.start(uri.host, uri.port) do |http|
            resp = http.get(uri.path)
            t.write(resp.body)
            t.flush
          end
          expect(File.read(t.path)).to eq File.read("spec/support/artwork.png")

          song_with_remote.artist = 'dj heartrider'
          song_with_remote.artwork = File.new("spec/support/artwork2.png")
          song_with_remote.save!
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj heartrider')
          uri = URI.parse(song_with_remote.artwork.url)
          t = Tempfile.new([File.basename(song_with_remote.artwork.path, ".*"), File.extname(song_with_remote.artwork.path)])
          t.binmode
          Net::HTTP.start(uri.host, uri.port) do |http|
            resp = http.get(uri.path)
            t.write(resp.body)
            t.flush
          end
          expect(File.read(t.path)).to eq File.read("spec/support/artwork2.png")
          downloaded_mp3 = download_mp3_tempfile song_with_remote.mp3_url
          expect(Rupeepeethree::Tagger.tags(downloaded_mp3.path).fetch(:artist)).to eq('dj heartrider')
        end
      end

      it "works with files in subdirectories on s3" do
        reset_tags
        reset_s3_object_in_subdir
        VCR.use_cassette "song_with_remote_in_subdirectory" do
          song_with_remote = SongWithS3.create(mp3: 'subdir/test.mp3')
          song_with_remote.reload
          expect(song_with_remote.artist).to eq('dj nameko')
          expect(song_with_remote.title).to eq('a cool song')

          uri = URI.parse(song_with_remote.artwork.url)
          t = Tempfile.new([File.basename(song_with_remote.artwork.path, ".*"), File.extname(song_with_remote.artwork.path)])
          t.binmode
          Net::HTTP.start(uri.host, uri.port) do |http|
            resp = http.get(uri.path)
            t.write(resp.body)
            t.flush
          end
          expect(File.read(t.path)).to eq File.read("spec/support/artwork.png")

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
