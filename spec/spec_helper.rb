require 'rspec'

require './spec/support/tags_macros.rb'

RSpec.configure do |config|
  config.include(TagsMacros)
  config.order = 'random'
end
