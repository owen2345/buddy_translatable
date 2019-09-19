# frozen_string_literal: true

I18n.available_locales = %i[de en es]

def prepare_database!
  db = 'translateable_test_db'.freeze

  ActiveRecord::Base.establish_connection(adapter: 'postgresql',
                                          database: 'template1',
                                          username: 'postgres')

  begin
    ActiveRecord::Base.connection.drop_database(db)
  rescue ActiveRecord::StatementInvalid
  end
  ActiveRecord::Base.connection.create_database(db)

  ActiveRecord::Base.establish_connection(adapter: 'postgresql',
                                          database: db,
                                          username: 'postgres')

  begin
    ActiveRecord::Base.connection.drop_table :test_models
  rescue ActiveRecord::StatementInvalid
  end

  migrate!
end

def migrate!
  ActiveRecord::Base.connection.create_table :test_models do |t|
    t.jsonb :title
    t.jsonb :key
  end
end

class TestModel < ActiveRecord::Base
  prepare_database!

  include BuddyTranslatable

  translatable :title, default_key: :de
  sales_datable :key, default_key: :vev
end