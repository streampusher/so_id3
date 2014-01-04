require 'rupeepeethree'

module SoId3
  class Tags
    attr_accessor :tagger
    attr_accessor :cache
    def initialize mp3, cache
      @mp3 = mp3
      @tagger = Rupeepeethree::Tagger
      @cache = cache
    end
    def artist
      # if cached? grab from database else grab from tags and store in db
      if !@cache.artist.nil?
        @cache.artist
      else
        artist = @tagger.tags(@mp3).fetch(:artist)
        @cache.artist=artist
        artist
      end
    end
    def artist=(text)
      # write tag with tagger and store in db
      tags = {}
      tags[:artist] = text
      @tagger.tag(@mp3, tags)
      @cache.artist=text
    end
    def title
      @tagger.tags(@mp3)[:title]
    end
    def title=(text)
      tags = {}
      tags[:title] = text
      @tagger.tag(@mp3, tags)
      @cache.title=text
    end
  end
end
