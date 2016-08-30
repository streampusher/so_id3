require 'spec_helper'

describe SoId3 do
  before :all do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                            database: "spec/support/so_id3.sqlite3")
    load "spec/support/schema.rb"
    ActiveRecord::Base.raise_in_transactional_callbacks = true
  end
  describe "#has_tags" do
    before :all do
      ActiveJob::Base.queue_adapter = :inline
    end
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
    describe "callback behavior" do
      before :all do
        ActiveJob::Base.queue_adapter = :test
      end
      it "doesn't enqueue the update tags job if none of the tag attributes changed" do
        expect do
          @song.attributes = { artist: 'dj heartrider', title: 'a cooler song', album: "hey" }
          @song.save
        end.to change{ActiveJob::Base.queue_adapter.enqueued_jobs.count}.by(1)
        expect do
          @song.another_column = "blah"
          @song.save
        end.to change{ActiveJob::Base.queue_adapter.enqueued_jobs.count}.by(0)
      end
    end
  end
end
