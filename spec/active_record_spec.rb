require 'spec_helper'
require 'so_id3/schema'
require 'so_id3/active_record'

describe SoId3::ActiveRecord do
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
  end
end
