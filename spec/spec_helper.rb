require 'dotenv'
Dotenv.load
require 'rspec'
require 'active_record'
require 'active_job'
require 'paperclip'
require 'so_id3'
require 'vcr'

require './spec/support/tags_macros.rb'
require './spec/support/song'
require './spec/support/song_with_s3'

RSpec.configure do |config|
  config.include(TagsMacros)
  config.order = 'random'
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb

  config.filter_sensitive_data("<S3_KEY>") do
    ENV.fetch 'S3_KEY', "x"*40
  end

  config.filter_sensitive_data("<S3_SECRET>") do
    ENV.fetch 'S3_SECRET', "x"*40
  end

  config.filter_sensitive_data("<S3_BUCKET>") do
    ENV.fetch 'S3_BUCKET', "x"*40
  end

  config.filter_sensitive_data("<S3_REGION>") do
    ENV.fetch 'S3_REGION', "x"*40
  end
end
