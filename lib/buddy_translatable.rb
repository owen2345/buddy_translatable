# frozen_string_literal: true

require 'buddy_translatable/version'
require 'buddy_translatable/configuration'
require 'buddy_translatable/core'
module BuddyTranslatable
  def self.config
    @config ||= Configuration.new
  end

  def self.included(base)
    base.extend BuddyTranslatable::Core
  end
end
