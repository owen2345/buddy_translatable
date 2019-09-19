# frozen_string_literal: true

module BuddyTranslatable
  class Configuration
    attr_accessor :available_sales_keys, :current_sales_key

    def initialize
      @available_sales_keys = %i[vev ebay]
    end

    def reset_current_sales_key
      @current_sales_key = nil
    end
  end
end