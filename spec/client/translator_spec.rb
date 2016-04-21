require 'spec_helper'

describe Distant::Translator do
  describe 'initialize' do
    before do
      @translator = described_class.new
    end
    it 'sets default from/to translators' do
      expect(@translator.from_hash_translator).to be_a Proc
      expect(@translator.to_hash_translator).to be_a Proc
    end
  end

  describe '#translate_from_hash(hash)' do
    before do
      @translator = described_class.new
      @translator.from_hash do |hash|
        secret = hash[:secret]
        {foo: secret}
      end
    end
    it 'uses the supplied translation block' do
      my_secret = SecureRandom.uuid
      result = @translator.translate_from_hash(secret: my_secret)
      expect(result).to eq(foo: my_secret)
    end
  end
  describe '#translate_to_hash(obj)' do
    before do
      @translator = described_class.new
      @translator.to_hash do |hash|
        secret = hash[:secret]
        {foo: secret}
      end
    end
    it 'uses the supplied translation block' do
      my_secret = SecureRandom.uuid
      result = @translator.translate_to_hash(secret: my_secret)
      expect(result).to eq(foo: my_secret)
    end
  end
  describe '#from_hash(&block)' do
    before do
      @translator = described_class.new
      @secret = SecureRandom.uuid
      @translator.from_hash do
        @secret
      end
    end
    it 'sets the block as the from_hash_translator' do
      expect(@translator.from_hash_translator.call).to eq @secret
    end
  end
  describe '#to_hash(&block)' do
    before do
      @translator = described_class.new
      @secret = SecureRandom.uuid
      @translator.to_hash do
        @secret
      end
    end
    it 'sets the block as the to_hash_translator' do
      expect(@translator.to_hash_translator.call).to eq @secret
    end
  end
  describe '#recursive_underscore(thing)' do
    context 'when given' do
      before do
        @translator = described_class.new
      end
      context 'an Array of hashes' do
        before do
          @data = [{'fooBar' => 'baz'}]
        end
        it 'calls recursive_underscore on all elements in the array' do
          expect(@translator.recursive_underscore(@data)).to eq([{foo_bar: 'baz'}])
        end
      end
      context 'a Hash' do
        before do
          @data = {'fooBar' => 'baz'}
        end
        it 'underscores the keys in the hash' do
          expect(@translator.recursive_underscore(@data)).to eq(foo_bar: 'baz')
        end
      end
      context 'anything else' do
        before do
          @data = 'Hello, World'
        end
        it 'returns the thing as-is' do
          expect(@translator.recursive_underscore(@data)).to eq(@data)
        end
      end
    end
  end
end
