# frozen_string_literal: true

require 'buddy_translatable/version'
require 'buddy_translatable/core'
module BuddyTranslatable
  def self.included(base)
    base.extend BuddyTranslatable::Core
  end
end
