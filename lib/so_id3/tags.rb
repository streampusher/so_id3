require 'rupeepeethree'

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
    def initialize mp3, cache
      @mp3 = mp3
      @tagger = Rupeepeethree::Tagger
      @cache = cache
    end
    VALID_TAGS.each do |tag_name|
      define_method tag_name do
        # if cached? grab from database else grab from tags and store in db
        if !@cache.send(tag_name).nil?
          @cache.send(tag_name)
        else
          tag = @tagger.tags(@mp3).fetch(tag_name.to_sym)
          @cache.send("#{tag_name}=", tag)
          tag
        end
      end
      define_method "#{tag_name}=" do |text|
        # write tag with tagger and store in db
        tags = {}
        tags[tag_name.to_sym] = text
        @tagger.tag(@mp3, tags)
        @cache.send("#{tag_name}=".to_sym, text)
      end
    end
  end
end
