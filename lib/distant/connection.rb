
module Distant
  class Connection
    include HTTParty

    attr_accessor :config
    def initialize(config)
      raise ArgumentError.new 'invalid config' unless config.is_a? Distant::Config
      self.config = config
      self.class.base_uri config.base_uri
    end
  end
end
