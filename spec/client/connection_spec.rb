require 'spec_helper'

describe Distant::Connection do
  describe '.configure' do
    context 'when a Distant::Config object' do
      context 'is provided' do
        it 'does not raise an exception' do
          config = Distant::Config.new
          config.debug = true
          expect{described_class.configure(config)}.not_to raise_error
        end
      end
      context 'is not provided' do
        it 'raises an exception' do
          expect{described_class.configure('a string')}.to raise_error ArgumentError
        end
      end
    end
  end
end
