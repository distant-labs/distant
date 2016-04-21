
module Distant
  class Config
    attr_accessor :base_uri, :auth_header_generator, :default_header_generator

    def initialize
      # Default just returns an empty hash:
      self.auth_header_generator = Proc.new{ {} }
      self.default_header_generator = Proc.new{ {} }
    end

    def set_authentication_headers_with(&block)
      raise ArgumentError.new 'block required' unless block_given?
      self.auth_header_generator = block
    end

    def set_default_headers_with(&block)
      raise ArgumentError.new 'block required' unless block_given?
      self.default_header_generator = block
    end

    def default_headers(body=nil)
      self.default_header_generator.call(body)
    end

    def auth_headers(body=nil)
      auth_header_generator.call(body)
    end
  end
end
