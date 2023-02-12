# JSON Buddy Translatable

Allows you to store text data in multiple languages. Based on [translateable](https://github.com/olegantonyan/translateable), but with a few differences:

1. Support for key methods
2. No extra table dependency
3. Single attribute
4. Support for `jsonb` and `text` format attributes

### Translations
```ruby
class Post < ActiveRecord::Base
  include BuddyTranslatable
  translatable :title
  # translatable :title, default_key: :de, available_locales: [:de, :en]
  # default_key: by default use `I18n.default_locale`
  # available_locales: by default `I18n.available_locales`
end

post = Post.create(title: { de: 'Hallo', en: 'Hello' })

# getter using current locale
I18n.locale = :en
post.title #=> Hello
I18n.locale = :de
post.title #=> Hallo

# Getter using methods
post.title_en #=> Hello
post.title_de #=> Hallo
post.title_for(:de) #=> Hallo
post.title_data_for(:en) #=> Hello
post.title_data # => return all data (Hash)

# Update current locale and maintain others
I18n.locale = :en
post.update(title: 'Hello changed')
post.title_en # => Hello changed
post.title_de # => Hallo
post.title_es # => Hallo (return default key if not found)
post.title_es = 'Hola' # => Set value for a specific locale
post.title_es # => Hola (return defined value)

# Replace all data
post.update(title: { en: 'En val', de: 'De val' })
post.title_en # => En val
post.title_es # => De val # default_key value is used when not defined
```

## Requirements
- ActiveRecord >= 4.2
- I18n

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'buddy_translatable', '>= 1.0'
```

Configure your available locales in your rails app, like:
```I18n.available_locales = %i[de en es]```

And then execute:
``` bundle install ```

## Usage

```ruby
class TestModel < ActiveRecord::Base
  include BuddyTranslatable

  translatable :title, default_key: :de
end
```

### Migration

Attributes must be `JSONB` type.
```ruby
class AddTitleToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :title, :jsonb, null: false, default: {}
    add_column :posts, :key, :jsonb, null: false, default: {}
    
    # for databases that does not support jsonb format
    # add_column :posts, :title, :text, null: false, default: '{}'
  end
end
```

### Filters

- Filter for an item with exact value in any locale
```ruby
# where_<attr_name>_with(value: String)
Post.where_key_with('ebay')
```

- Filter for items with any locale that contains the provided value
```ruby
# where_<attr_name>_like(value: String)
Post.where_key_like('bay')
```

- Filter for items where current locale has the exact provided value
```ruby
# where_<attr_name>_eq(value: String, locale?: Symbol)
Post.where_key_eq('ebay')
```

## Development
Run tests with:    
`docker-compose run test bash -c "rspec"`    
Check code style:    
`docker-compose run test bash -c "rubocop"`    


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/owen2345/buddy_translatable.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

