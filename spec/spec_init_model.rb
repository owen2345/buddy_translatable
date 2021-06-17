# frozen_string_literal: true

I18n.available_locales = %i[de en es]

def prepare_database!
  db = 'translatable_test_db'
  connect_db('template1')
  ActiveRecord::Base.connection.drop_database(db) rescue nil
  ActiveRecord::Base.connection.create_database(db)
  connect_db(db)
  ActiveRecord::Base.connection.drop_table :test_models rescue nil
  migrate!
end

def connect_db(db)
  ActiveRecord::Base.establish_connection(adapter: 'postgresql',
                                          database: db,
                                          username: 'root',
                                          password: 'password',
                                          host: 'postgres')
end

def migrate!
  ActiveRecord::Base.connection.create_table :test_models do |t|
    t.jsonb :title
    t.jsonb :key
    t.string :title_text, default: '{}'
  end
end

class TestModel < ActiveRecord::Base
  prepare_database!

  include BuddyTranslatable

  translatable :title, default_key: :de
  translatable :title_text, default_key: :de
end
