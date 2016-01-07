require 'spec_helper'
require 'so_id3/tags'

class FakeTagger
  def tags(mp3)
    {
      artist: 'dj nameko',
      title: 'a cool song',
      album: 'hey',
      year: '0',
      track: '3',
      length: '120',
    }
  end
  def tag(file, tags)
  end
end

describe SoId3::Tags do
  before :each do
    reset_tags
    tags.tagger = tagger
  end
  let(:mp3)  { "spec/support/test.mp3" }
  let(:cache) { double('cache') }
  let(:tagger) { FakeTagger.new }
  let(:tags) { SoId3::Tags.new(mp3, cache) }

  describe 'SoId3::Tags' do
    describe "sync_tags_from_file_to_db" do
      it "saves tags from the file to the database" do
        expect(cache).to receive(:write_attribute).with("artist", "dj nameko")
        expect(cache).to receive(:write_attribute).with("title", "a cool song")
        expect(cache).to receive(:write_attribute).with("album", "hey")
        expect(cache).to receive(:write_attribute).with("year", "0")
        expect(cache).to receive(:write_attribute).with("track", "3")
        expect(cache).to receive(:write_attribute).with("length", "120")
        expect(cache).to receive(:save!)
        tags.sync_tags_from_file_to_db
      end
    end
    describe "sync_tags_from_db_to_file" do
      it "saves tags from the db to the file" do
        expect(cache).to receive(:read_attribute).with("artist")
        expect(cache).to receive(:read_attribute).with("title")
        expect(cache).to receive(:read_attribute).with("album")
        expect(cache).to receive(:read_attribute).with("year")
        expect(cache).to receive(:read_attribute).with("track")
        expect(cache).to receive(:read_attribute).with("length")
        tags.sync_tags_from_db_to_file
      end
    end
  end
end
