require 'spec_helper'
require 'so_id3/tags'

class FakeTagger
  def self.tags(mp3)
    {artist: 'dj nameko'}
  end
end

describe SoId3::Tags do
  before :each do
    reset_tags
    tags.tagger = tagger
  end
  let(:mp3)  { "spec/support/test.mp3" }
  let(:cache) { double('cache') }
  let(:tagger) { FakeTagger }
  let(:tags) { SoId3::Tags.new(mp3, cache) }

  describe 'reading tags' do
    context 'when not cached in the database' do
      it 'reads from the file then stores in the database' do
        tags.cache.stub(:read_attribute).with("artist"){ nil }
        tags.cache.stub(:write_attribute)

        tags.cache.should_receive(:update_attribute).with('artist', "dj nameko")

        expect(tags.artist).to eq 'dj nameko'
      end
    end

    context 'when cached in the database' do
      it 'reads from the database and not from the file' do
        tags.cache.stub(:read_attribute).with("artist"){ "dj nameko" }

        tags.cache.should_receive(:read_attribute).with("artist")
        tags.cache.should_not_receive(:artist=)

        tags.artist
      end
    end
  end

  describe 'writing tags' do
    it 'writes the tag with the tagger and stores the tag in the cache' do
      tagger.stub(:tag)

      new_title = 'cool new tune'
      new_tags = {title: new_title }

      tagger.should_receive(:tag).with(mp3, new_tags)
      cache.should_receive(:update_attribute).with('title', new_title)

      tags.title=new_title
    end
  end
end
