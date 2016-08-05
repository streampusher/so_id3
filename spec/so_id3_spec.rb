require 'spec_helper'
require 'byebug'

describe SoId3 do
  before :all do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                            database: "spec/support/so_id3.sqlite3")
    load "spec/support/schema.rb"
    ActiveRecord::Base.raise_in_transactional_callbacks = true
    ActiveJob::Base.queue_adapter = :inline
  end
  describe "#has_tags" do
    context "with local files" do
      before :each do
        reset_tags
        @song = Song.create(mp3: "spec/support/test.mp3")
        @song.reload
      end
      it "fetches tags from the file to the db" do
        expect(@song.artist).to eq 'dj nameko'
        expect(@song.title).to eq 'a cool song'
        expect(@song.length).to eq 2
        expect(File.read(@song.artwork.path)).to eq File.read("spec/support/artwork.png")
      end
      it 'writes tags from the db to the file' do
        @song.artist = 'dj heartrider'
        @song.artwork = File.new("spec/support/artwork2.png")
        @song.save
        @song.reload
        expect(Rupeepeethree::Tagger.tags(@song.mp3).fetch(:artist)).to eq('dj heartrider')
        expect(Rupeepeethree::Tagger.tags(@song.mp3).fetch(:picture)[:mime_type]).to eq "image/png"
      end
      it 'works with a hash of attributes' do
        @song.attributes = { artist: 'dj heartrider', title: 'a cooler song', album: "hey" }
        @song.save
        expect(Rupeepeethree::Tagger.tags(@song.mp3).fetch(:artist)).to eq('dj heartrider')
        expect(Rupeepeethree::Tagger.tags(@song.mp3).fetch(:title)).to eq('a cooler song')
        expect(Rupeepeethree::Tagger.tags(@song.mp3).fetch(:album)).to eq('hey')
      end
    end
  end
end
