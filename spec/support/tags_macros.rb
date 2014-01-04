module TagsMacros
  def reset_tags
    tags = {}
    tags[:artist] = 'dj nameko'
    tags[:title] = 'a cool song'
    Rupeepeethree::Tagger.tag("spec/support/test.mp3",tags)
  end
end
