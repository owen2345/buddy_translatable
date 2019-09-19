# frozen_string_literal: true

module BuddyTranslatable
  module Core
    def translatable(*attrs, default_key: :de, available_keys: [])
      available_keys = I18n.available_locales unless available_keys.present?
      attrs.each do |attr|
        translatable_sanity_check(attr)
        define_translatable_methods(attr, default_key)
        define_translatable_key_methods(attr, available_keys)
      end
    end

    def sales_datable(*attrs, default_key: :vev, available_keys: [])
      unless available_keys.present?
        available_keys = BuddyTranslatable.config.available_sales_keys
      end
      attrs.each do |attr|
        translatable_sanity_check(attr)
        define_translatable_methods(attr, default_key, is_locale: false)
        define_translatable_key_methods(attr, available_keys)
      end
    end

    def translatable_sanity_check(attr)
      msg = "no such column '#{attr}' in '#{name}' model"
      raise ArgumentError, msg unless column_names.include?(attr.to_s)
    end

    def define_translatable_methods(attr, default_key, is_locale: true)
      current_key = lambda do
        res = I18n.locale
        current_sales_key = BuddyTranslatable.config.current_sales_key
        res = current_sales_key || default_key unless is_locale
        res.to_sym
      end
      define_translatable_setters(attr, current_key)
      define_translatable_key_getters(attr, default_key)
      define_translatable_getters(attr, current_key)
    end

    def define_translatable_setters(attr, current_key)
      define_method("#{attr}_data=") do |arg|
        data = send("#{attr}_data")
        self[attr] = arg.is_a?(Hash) ? arg : data.merge(current_key.call => arg)
      end

      define_method("#{attr}=") do |arg|
        send("#{attr}_data=", arg)
      end
    end

    def define_translatable_key_getters(attr, default_key)
      define_method("#{attr}_data_for") do |key|
        value = send("#{attr}_data")
        value[key] ||
          value[default_key].presence ||
          value.values.find(&:present?)
      end
    end

    def define_translatable_getters(attr, current_key)
      define_method("#{attr}_data") do
        res = self[attr]
        res = new_record? ? { current_key.call => '' } : {} unless res.present?
        res.with_indifferent_access
      end

      define_method(attr) do |**_args|
        send("#{attr}_data_for", current_key.call)
      end
    end

    def define_translatable_key_methods(attr, keys)
      keys.each do |key|
        define_method("#{attr}_#{key}") do
          send("#{attr}_data_for", key)
        end
      end
    end
  end
end