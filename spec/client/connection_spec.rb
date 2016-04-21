require 'spec_helper'

describe Distant::Connection do
  describe 'initialization' do
    context 'when a Distant::Config object' do
      context 'is provided' do
        it 'returns a new Distant::Connection object' do
          expect(described_class.new(Distant::Config.new)).to be_a described_class
        end
      end
      context 'is not provided' do
        it 'raises an exception' do
          expect{described_class.new('a string')}.to raise_error ArgumentError
        end
      end
    end
  end
end
