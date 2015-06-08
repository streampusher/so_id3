require 'rspec'
require 'vcr'

require './spec/support/tags_macros.rb'

RSpec.configure do |config|
  config.include(TagsMacros)
  config.order = 'random'
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb

  config.filter_sensitive_data("<S3_KEY>") do
    ENV['S3_KEY']
  end

  config.filter_sensitive_data("<S3_SECRET>") do
    ENV['S3_SECRET']
  end

  config.define_cassette_placeholder("<S3_BUCKET>") do
    ENV['S3_BUCKET']
  end
end
