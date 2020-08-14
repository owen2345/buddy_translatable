# frozen_string_literal: true

module BuddyTranslatable
  module Core
    def translatable(*attrs, default_key: :en, available_keys: nil)
      available_keys ||= I18n.available_locales
      attrs.each do |attr|
        define_translatable_methods(attr, default_key)
        define_translatable_key_methods(attr, available_keys)
      end
    end

    def define_translatable_methods(attr, default_key)
      define_translatable_setters(attr)
      define_translatable_key_getters(attr, default_key)
      define_translatable_getters(attr)
    end

    def define_translatable_setters(attr)
      define_method("#{attr}_data=") do |arg|
        data = send("#{attr}_data")
        self[attr] = arg.is_a?(Hash) ? arg : data.merge(I18n.locale => arg)
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

      define_method("#{attr}_for") do |key|
        send("#{attr}_data_for", key)
      end
    end

    def define_translatable_getters(attr)
      define_method("#{attr}_data") do
        res = self[attr]
        res = new_record? ? { I18n.locale => '' } : {} unless res.present?
        res.symbolize_keys.with_indifferent_access
      end

      define_method(attr) do |**_args|
        send("#{attr}_data_for", I18n.locale)
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