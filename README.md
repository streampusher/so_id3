# SoId3

associate mp3 tags with active record models

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
rails g so_id3:install
```

Declare the tags on your model. Specify a string column containing the path to
the mp3 file (can be local or remote).
```
class Track < ActiveRecord::Base
  has_tags column: mp3_file_name, storage: :local
end
```

This adds an 'id3_tags' method to your model.

```
> t = Track.new
> t.id3_tags.title = 'Wow cool song'
> t.id3_tags.save
> t.id3_tags.title
> 'Wow cool song'
```

If you are dealing with big files you may want to save the tags in a background
job.

If you edited the tags outside of rails you can force a 'refresh' of the tags,
which will read the tags from the file and update the database fields.

```
> t.refresh!
```

A few validations are provided as well.

```
validates_id3_tag_presence :title, :artist
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
