
module Distant
  class Connection
    include HTTParty

    def self.configure(config)
      raise ArgumentError.new 'invalid config' unless config.is_a? Distant::Config
      self.base_uri config.base_uri
      if config.debug
        self.debug_output
      end
      self
    end
  end
end
