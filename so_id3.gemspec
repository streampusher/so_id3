# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'so_id3/version'

Gem::Specification.new do |spec|
  spec.name          = "so_id3"
  spec.version       = SoId3::VERSION
  spec.authors       = ["Tony Miller"]
  spec.email         = ["mcfiredrill@gmail.com"]
  spec.description   = %q{add mp3 tags to your ActiveRecord models}
  spec.summary       = %q{mp3 tags as attributes for ActiveRecord}
  spec.homepage      = "https://github.com/streampusher/so_id3"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activerecord'
  spec.add_dependency 'activejob'
  spec.add_dependency 'rupeepeethree', '~> 0.0.7'
  spec.add_dependency 'aws-sdk-s3', '~> 1'
  spec.add_development_dependency "bundler", "~> 2.2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "vcr", "~> 3"
  spec.add_development_dependency "webmock"
end
