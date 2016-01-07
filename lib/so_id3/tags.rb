require 'rupeepeethree'
require 'open-uri'
require 'aws-sdk'

module SoId3
  class Tags
    VALID_TAGS = [
      'artist',
      'title',
      'album',
      'year',
      'track',
      'length'
    ]

    attr_accessor :tagger
    attr_accessor :cache

    def initialize mp3_filename, cache, storage=:filesystem, s3_credentials = {}
      @mp3_filename = mp3_filename
      @tagger = Rupeepeethree::Tagger
      @cache = cache
      @storage = storage.to_sym
      @s3_credentials = s3_credentials
    end

    # sync_tags
    # file <=> db
    def sync_tags_from_file_to_db
      @mp3_tempfile = get_tempfile
      VALID_TAGS.each do |tag_name|
        tag = @tagger.tags(@mp3_tempfile).fetch(tag_name.to_sym, nil)
        @cache.send(:write_attribute, tag_name, tag)
      end
      @cache.send(:save!)
    end

    # update_tags
    # db <=> file
    def sync_tags_from_db_to_file
      @mp3_tempfile = get_tempfile
      tags = {}
      VALID_TAGS.each do |tag_name|
        text = @cache.send(:read_attribute, tag_name)
        tags[tag_name.to_sym] = text
      end
      @tagger.tag(@mp3_tempfile, tags)
      if @storage == :s3
        write_file_to_s3
      end
    end

    private

    def get_tempfile
      if @storage == :s3
        @s3 = AWS::S3.new(access_key_id: @s3_credentials[:access_key_id],
                          secret_access_key: @s3_credentials[:secret_access_key])
        @bucket = @s3.buckets.create(@s3_credentials[:bucket])
        @mp3_tempfile = get_file_from_s3(@mp3_filename)
      else
        @mp3_tempfile = @mp3_filename
      end
      @mp3_tempfile
    end

    def write_tag_to_cache tag_name, text
      @cache.send(:write_attribute, tag_name, text)
    end

    def write_tag_to_cache_and_save tag_name, text
      @cache.send(:write_attribute, tag_name, text)
      @cache.send(:save!)
      # maybe it would be desired to have this method trigger callbacks?
    end

    def write_file_to_s3
      key = File.basename(@mp3_filename)
      puts "the key: #{key}"
      @bucket.objects[key].write(file: @mp3_tempfile, acl: :public_read)
    end

    def get_file_from_s3 filename
      obj = @bucket.objects[filename]
      # streaming download from S3 to a file on disk
      t = Tempfile.new([File.basename(filename, ".*"), File.extname(filename)])
      t.binmode
      obj.read do |chunk|
        t.write(chunk)
      end
      t.rewind
      t.path
    end
  end
end
