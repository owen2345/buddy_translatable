# JSON Buddy Translatable

Allows you to store text data in multiple languages or Sales channels. Based on [translateable](https://github.com/olegantonyan/translateable), but with a few differences:

1. Support for key methods
2. Support for Sales channels

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
```

### Sales Channels
```ruby
class Post < ActiveRecord::Base
  include BuddyTranslatable
  sales_datable :key, default_key: :vev
end
post = Post.create(key: { vev: 'vev', ebay: 'ebay' })

# getter
post.key #=> vev # return default key
BuddyTranslatable.config.current_sales_key = :ebay
post.key #=> ebay

# you can reset current sales channel by
BuddyTranslatable.config.reset_current_sales_key

# Getter using methods
post.key_vev #=> vev
post.key_ebay #=> ebay
post.key_for(:ebay) #=> ebay
post.key_data_for(:vev) #=> vev
post.key_data # => return all data (Hash)

# Update current sales key (if empty will use default_key) and maintain others
BuddyTranslatable.config.current_sales_key = :ebay 
post.update(key: 'Ebay changed')
post.key_ebay # => Ebay changed
post.key_vev # => vev

# Replace all data
post.update(key: { vev: 'vev val', ebay: 'ebay val' })
post.key_vev # => vev val
```

## Requirements

- PostgreSQL >= 9.4
- ActiveRecord >= 4.2
- I18n

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'buddy_translatable'
```

Create initializer:
```ruby
# config/initializers/translatable.rb
BuddyTranslatable.config.available_sales_keys = %i[de ebay]
I18n.available_locales = %i[de en es]
```

And then execute:
``` bundle install ```

## Usage

```ruby
class TestModel < ActiveRecord::Base
  include BuddyTranslatable

  translatable :title, default_key: :de
  sales_datable :key, default_key: :vev #, available_keys: [:ebay, :amazon, :vev]
end
```

### Migration

Attributes must be `JSONB` type.
```ruby
class AddTitleToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :title, :jsonb, null: false, default: {}
    add_column :posts, :key, :jsonb, null: false, default: {}
  end
end
```

### Queries

For searching you can use the following concern:
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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/owen2345/buddy_translatable.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
