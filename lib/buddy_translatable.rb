# frozen_string_literal: true

require 'buddy_translatable/version'
require 'buddy_translatable/core'
module BuddyTranslatable
  def self.included(base)
    base.extend BuddyTranslatable::Core
  end

  def self.parse_translatable_data(data)
    res = data || {}
    res = {} unless res.present?
    res = JSON.parse(res) if res.is_a?(String)
    res.symbolize_keys
  end

  def self.translatable_attr_json?(model_class, attr)
    migrated = ActiveRecord::Base.connection.tables.include?(model_class.table_name)
    return :text unless migrated

    columns_data = model_class.try(:column_types) || model_class.try(:attribute_types)
    format = (columns_data[attr.to_s].type rescue :text) # rubocop:disable Style/RescueModifier
    %i[string text].exclude?(format)
  end
end
