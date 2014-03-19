require 'spec_helper'
require 'so_id3/tags'

describe SoId3::Tags do
  before :each do
    reset_tags
    tags.tagger = tagger
  end
  let(:mp3)  { "spec/support/test.mp3" }
  let(:cache) { double('cache') }
  let(:tagger) { double('tagger') }
  let(:tags) { SoId3::Tags.new(mp3, cache, :file) }

  # first read should read tags from file, then store them in the database
  #
  # then next read should read from database

  describe 'reading tags' do
    context 'when not cached in the database' do
      it 'reads from the file then stores in the database' do
        tagger.stub(:tags)
        tagger.tags.stub(:fetch).with(:artist) { "dj nameko" }
        tags.cache.stub(:artist){ nil }
        tags.cache.stub(:artist=)

        tagger.should_receive(:tags).with(mp3)
        tagger.tags.should_receive(:fetch).with(:artist)
        tags.cache.should_receive(:artist=).with("dj nameko")

        tags.artist
      end
    end
    context 'when cached in the database' do
      it 'read from the database and not from the file' do
        tagger.stub(:tags)
        tagger.tags.stub(:fetch).with(:artist)
        tags.cache.stub(:artist) { "dj nameko" }

        tagger.should_not_receive(:tags).with(mp3)
        tagger.tags.should_not_receive(:fetch).with(:artist)
        tags.cache.should_receive(:artist)

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
      cache.should_receive(:title=).with(new_title)

      tags.title=new_title
    end
  end
end
