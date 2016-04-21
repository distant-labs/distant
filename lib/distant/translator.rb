
module Distant
  class Translator
    attr_accessor :from_hash_translator, :to_hash_translator

    def initialize
      # Sensible defaults:
      self.from_hash_translator = Proc.new{ |hash| hash }
      self.to_hash_translator = Proc.new{ |obj| obj.to_h }
    end

    def translate_from_hash(hash)
      self.from_hash_translator.call(hash)
    end

    def translate_to_hash(obj)
      self.to_hash_translator.call(obj)
    end

    def from_hash(&block)
      self.from_hash_translator = block
    end

    def to_hash(&block)
      self.to_hash_translator = block
    end

    def recursive_underscore(thing)
      if thing.is_a? Hash
        out = {}
        thing.each do |key, val|
          out[key.to_s.underscore.to_sym] = recursive_underscore(val)
        end
        out
      elsif thing.is_a? Array
        thing.map{ |item| recursive_underscore(item) }
      else
        thing
      end
    end
  end
end
