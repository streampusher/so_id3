require 'spec_helper'
require 'so_id3/schema'

class Track < ActiveRecord::Base; end

describe SoId3::Schema do
  before :all do
    ActiveRecord::Base.establish_connection(adapter: "sqlite3",
                                            database: "spec/support/so_id3.sqlite3")
  end
  after :each do
    ActiveRecord::Base.connection.drop_table :tracks
  end
  it 'uses id3_tags schema statement' do
    ActiveRecord::Base.connection.create_table :tracks, force: true do |t|
      t.string :mp3
      t.id3_tags
    end

    Track.reset_column_information

    ["artist", "title", "album", "year", "track"].each do |t|
      expect(Track.column_names).to include(t)
    end
  end
  it 'uses add_id3_tags' do
    ActiveRecord::Base.connection.create_table :tracks, force: true do |t|
      t.string :mp3
    end

    ActiveRecord::Base.connection.add_id3_tags :tracks

    Track.reset_column_information

    ["artist", "title", "album", "year", "track"].each do |t|
      expect(Track.column_names).to include(t)
    end
  end
  it 'uses remove_id3_tags' do
    ActiveRecord::Base.connection.create_table :tracks, force: true do |t|
      t.string :mp3
      t.id3_tags
    end

    ActiveRecord::Base.connection.remove_id3_tags :tracks

    Track.reset_column_information

    ["artist", "title", "album", "year", "track"].each do |t|
      expect(Track.column_names).to_not include(t)
    end
  end
end
