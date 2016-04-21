
require 'active_support/core_ext/object'
require 'active_support/json'
require 'httparty'
require 'logger'
require 'ostruct'
require 'distant/config'
require 'distant/translator'
require 'distant/base'
require 'distant/connection'

module Distant

  def self.configure(&block)
    @@config = Distant::Config.new
    block.call(@@config)
    config
  end

  def self.config
    @@config
  end
end
