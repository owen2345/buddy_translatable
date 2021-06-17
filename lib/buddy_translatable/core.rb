# frozen_string_literal: true

module BuddyTranslatable
  module Core
    def translatable(*attrs, default_key: :en, available_locales: nil)
      available_locales ||= I18n.available_locales
      attrs.each do |attr|
        define_translatable_methods(attr, default_key.to_sym)
        define_translatable_key_methods(attr, available_locales.map(&:to_sym))
      end
    end

    def define_translatable_methods(attr, fallback_locale)
      format = respond_to?(:column_types) ? column_types[attr.to_s].type : attribute_types[attr.to_s].type
      define_translatable_setters(attr, format)
      define_translatable_key_getters(attr, fallback_locale)
      define_translatable_getters(attr)
    end

    def define_translatable_setters(attr, format)
      define_method("#{attr}_data=") do |arg|
        data = send("#{attr}_data")
        data = arg.is_a?(Hash) ? arg.symbolize_keys : data.merge(I18n.locale => arg)
        self[attr] = %i[string text].include?(format) ? data.to_json : data
      end

      define_method("#{attr}=") do |arg|
        send("#{attr}_data=", arg)
      end
    end

    def define_translatable_key_getters(attr, fallback_locale)
      define_method("#{attr}_data_for") do |key|
        value = send("#{attr}_data")
        value[key] ||
          value[fallback_locale].presence ||
          value.values.find(&:present?)
      end

      define_method("#{attr}_for") do |key|
        send("#{attr}_data_for", key)
      end
    end

    def define_translatable_getters(attr)
      define_method("#{attr}_data") do
        res = self[attr] || {}
        res = new_record? ? { I18n.locale => '' } : {} unless res.present?
        res = JSON.parse(res) if res.is_a?(String)
        res.symbolize_keys
      end

      define_method(attr) do |**_args|
        send("#{attr}_data_for", I18n.locale)
      end
    end

    def define_translatable_key_methods(attr, locales)
      locales.each do |key|
        define_method("#{attr}_#{key}") do
          send("#{attr}_data_for", key)
        end
      end
    end
  end
end
