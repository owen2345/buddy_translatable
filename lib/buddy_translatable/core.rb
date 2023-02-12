# frozen_string_literal: true

module BuddyTranslatable
  module Core
    def translatable(*attrs, default_key: I18n.default_locale, available_locales: nil)
      available_locales ||= I18n.available_locales
      attrs.each do |attr|
        define_translatable_methods(attr, default_key.to_sym)
        define_translatable_key_methods(attr, available_locales.map(&:to_sym))
      end
    end

    def define_translatable_methods(attr, fallback_locale)
      is_json = BuddyTranslatable.translatable_attr_json?(self, attr)
      define_translatable_setters(attr, is_json)
      define_translatable_key_getters(attr, fallback_locale)
      define_translatable_getters(attr)
      define_translatable_finders(attr, is_json)
    end

    # Sample:
    #   model.title_data = { de: 'de val', en: 'en val' } # ==> replace value data
    #   model.title = { de: 'de val', en: 'en val' } # replace value data
    #   model.title = 'custom value' # sets new value for current locale
    def define_translatable_setters(attr, is_json)
      define_method("#{attr}_data=") do |arg|
        data = send("#{attr}_data")
        data = arg.is_a?(Hash) ? arg.symbolize_keys : data.merge(I18n.locale => arg)
        self[attr] = is_json ? data : data.to_json
      end

      define_method("#{attr}=") do |arg|
        send("#{attr}_data=", arg)
      end
    end

    # Sample:
    #   model.title_for(:de) # ==> print value for provided locale
    #   model.title_data_for(:de) # print value for provided locale
    def define_translatable_key_getters(attr, fallback_locale)
      define_method("#{attr}_data_for") do |key|
        value = send("#{attr}_data")
        value[key].presence ||
          value[fallback_locale].presence ||
          value.values.find(&:present?)
      end

      define_method("#{attr}_for") do |key|
        send("#{attr}_data_for", key)
      end
    end

    # Sample:
    #   model.title_data # ==> print values data
    #   model.title # print value for current locale
    def define_translatable_getters(attr)
      define_method("#{attr}_data") do
        BuddyTranslatable.parse_translatable_data(self[attr])
      end

      define_method(attr) do |**_args|
        send("#{attr}_data_for", I18n.locale)
      end
    end

    # Sample:
    #   model.title_de # ==> "de title"
    #   model.title_de = "new title" # assign value for specific locale
    def define_translatable_key_methods(attr, locales)
      locales.each do |locale|
        define_method("#{attr}_#{locale}") do
          send("#{attr}_data_for", locale)
        end

        define_method("#{attr}_#{locale}=") do |value|
          data = send("#{attr}_data").merge(locale => value)
          send("#{attr}_data=", data)
        end
      end
    end

    # Sample string value: {\"en\":\"key-1\"}
    def define_translatable_finders(attr, is_json) # rubocop:disable Metrics/MethodLength Metrics/AbcSize
      attr_query = sanitize_sql("#{table_name}.#{attr}")
      scope :"where_#{attr}_with", (lambda do |value|
        return where("#{attr_query} like ?", "%\":\"#{value}\"%") unless is_json

        where("EXISTS (SELECT 1 FROM jsonb_each_text(#{attr_query}) j WHERE j.value = ?)", value)
      end)

      scope :"where_#{attr}_like", (lambda do |value|
        return where("#{attr_query} like ?", "%#{value}%") unless is_json

        where("EXISTS (SELECT 1 FROM jsonb_each_text(#{attr_query}) j WHERE j.value LIKE ?)", "%#{value}%")
      end)

      scope :"where_#{attr}_eq", (lambda do |value, locale = I18n.locale|
        return where("#{attr_query} like ?", "%\"#{locale}\":\"#{value}\"%") unless is_json

        where("#{attr}->>'#{locale}' = ?", value)
      end)
    end
  end
end
