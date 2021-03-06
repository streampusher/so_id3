# SoId3

[![Build Status](https://img.shields.io/travis/streampusher/so_id3/master.svg)](https://travis-ci.org/streampusher/so_id3)

associate mp3 tags with active record models

# VERY BETA NO DON'T

```
wow
   such tagged mp3
 so id3
```

## Installation

Add this line to your application's Gemfile:

    gem 'so_id3'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install so_id3

## Usage

Run the generator to get the migration needed.

```
rails g so_id3 Track
```

Use the `add_id3_tags` method in your migration to add the necessary columns to
store the tags in the database.

```ruby
class AddId3TagsToTracks < ActiveRecord::Migration
  def self.up
    add_id3_tags :tracks
  end
end
```

This just adds simple string columns to your model like title, artist, etc.

Declare the tags on your model. Specify a string column containing the path to
the mp3 file (can be filesystem or s3).
```
class Track < ActiveRecord::Base
  has_tags column: mp3_file_name, storage: :filesystem
end
```

```
class Track < ActiveRecord::Base
  has_tags column: :mp3_file_name, storage: :s3,
           s3_credentials: { bucket: ENV['S3_BUCKET'],
                             access_key_id: ENV['S3_KEY'],
                             secret_access_key: ENV['S3_SECRET'] }
end
```

This adds an `tags` method to your model.

```
> t = Track.new
> t.tags.title
> 'Wow cool song'
> t.tags.artist
> 'dj wow'
```

However you can access the tags as normal attributes and the id3 tags in the
file itself will be updated, its recommended you use the library this way.

```
> t = Track.find(3)
> t.title = 'new title'
> t.save!
> t.title
> 'new title'
> t.tags.title
> 'new title'
```

If you are dealing with big files you may want to save the tags in a background
job, especially if the files are remote.

If you edited the tags outside of rails you can force a 'refresh' of the tags,
which will read the tags from the file and update the database fields.

```
> t.refresh!
```

A few validations are provided as well.

```
validates_id3_tag_presence :title, :artist
```

This will make sure the tags are actually in the file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
