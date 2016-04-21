require 'spec_helper'

describe Distant do
  describe '.configure{|config| ... }' do
    context 'the provided block' do
      it 'is executed' do
        @was_executed = false
        Distant.configure do |config|
          @was_executed = true
        end
        expect(@was_executed).to be_truthy
      end
      it 'is provided a config object as an argument' do
        @config_obj = nil
        Distant.configure do |config|
          @config_obj = config
        end
        expect(@config_obj).to be_a Distant::Config
      end
    end
  end
end
