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
  translatable :title, default_key: :de
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

### Queries

For searching you can use the following concern (Only `jsonb` format attributes):
```ruby
module JsonbQuerable
  extend ActiveSupport::Concern

  included do
    scope :where_jsonb_value, lambda { |attr, value|
      attr_query = sanitize_sql("#{table_name}.#{attr}")
      where("EXISTS (SELECT 1 FROM jsonb_each_text(#{attr_query}) j
                              WHERE j.value = ?)", value)
    }

    scope :where_jsonb_value_like, lambda { |attr, value, case_sens = false|
      attr_query = sanitize_sql("#{table_name}.#{attr}")
      condition = case_sens ? 'j.value LIKE ?' : 'lower(j.value) LIKE lower(?)'
      where("EXISTS (SELECT 1
                     FROM jsonb_each_text(#{attr_query}) j
                     WHERE #{condition})", "%#{value}%")
    }
  end
end

class Post < ActiveRecord::Base
  #...
  include JsonbQuerable
  #...
end

Post.where_jsonb_value_like(:key, 'ebay')
```
Simple queries:
```ruby
Post.where("title->>'en' = ?", 'hello')
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

