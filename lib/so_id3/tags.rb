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
      'track'
    ]

    attr_accessor :tagger
    attr_accessor :cache

    def initialize mp3_filename, cache, storage=:filesystem, s3_credentials = {}
      if storage == :s3
        @s3 = AWS::S3.new(access_key_id: s3_credentials[:access_key_id],
                          secret_access_key: s3_credentials[:secret_access_key])
        @bucket = @s3.buckets.create(s3_credentials[:bucket])
        @mp3_filename = mp3_filename
        @mp3_tempfile = get_file_from_s3(mp3_filename)
      else
        @mp3_tempfile = mp3_filename
      end
      @tagger = Rupeepeethree::Tagger
      @cache = cache
      @storage = storage.to_sym
    end

    # accepts a hash of tag values
    #
    # useful for updating tags all at once in a background process
    def update_tags(tags)

    end

    VALID_TAGS.each do |tag_name|

      define_method tag_name do
        # if cached? grab from database else grab from tags and store in db
        if !@cache.send(:read_attribute, tag_name).nil?
          @cache.send(:read_attribute, tag_name)
        else
          tag = @tagger.tags(@mp3_tempfile).fetch(tag_name.to_sym)
          write_tag_to_cache_and_save tag_name, tag
          tag
        end
      end

      define_method "#{tag_name}=" do |text|
        # write tag with tagger and store in db
        tags = {}
        tags[tag_name.to_sym] = text
        @tagger.tag(@mp3_tempfile, tags)
        if @storage == :s3
          # grab file from s3
          # store in /tmp/
          # tag
          # re-upload to s3
          key = File.basename(@mp3_filename)
          @bucket.objects[key].write(file: @mp3_tempfile, acl: :public_read)
          # re-download?
          @mp3_tempfile = get_file_from_s3(key)
        end
        write_tag_to_cache tag_name, text
      end

    end

    private
    def write_tag_to_cache tag_name, text
      @cache.send(:write_attribute, tag_name, text)
    end

    def write_tag_to_cache_and_save tag_name, text
      @cache.send(:write_attribute, tag_name, text)
      @cache.send(:save!)
      # maybe it would be desired to have this method trigger callbacks?
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
