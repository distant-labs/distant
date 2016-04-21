require 'spec_helper'

describe Distant::Config do
  context 'accessors' do
    let(:subject){ Distant::Config.new }
    it { should respond_to :base_uri }
    it { should respond_to :base_uri= }
    it { should respond_to :set_authentication_headers_with }
    it { should respond_to :set_default_headers_with }
  end

  describe '#set_authentication_headers_with(&block)' do
    before do
      @config = described_class.new
    end
    context 'when called' do
      context 'with a block' do
        before do
          @secret = SecureRandom.uuid
          @config.set_authentication_headers_with do |body|
            {secret: @secret, body: body}
          end
        end
        it 'will execute the block when #auth_headers(body) is called' do
          body = SecureRandom.uuid
          expect(@config.auth_headers(body)).to eq(secret: @secret, body: body)
        end
      end
      context 'without a block' do
        it 'raises an exception' do
          expect{@config.set_authentication_headers_with()}.to raise_error ArgumentError
        end
      end
    end
  end

  describe '#set_default_headers_with(&block)' do
    before do
      @config = described_class.new
    end
    context 'when called' do
      context 'with a block' do
        before do
          @secret = SecureRandom.uuid
          @config.set_default_headers_with do |body|
            {secret: @secret, body: body}
          end
        end
        it 'will execute the block when #auth_headers(body) is called' do
          body = SecureRandom.uuid
          expect(@config.default_headers(body)).to eq(secret: @secret, body: body)
        end
      end
      context 'without a block' do
        it 'raises an exception' do
          expect{@config.set_default_headers_with()}.to raise_error ArgumentError
        end
      end
    end
  end
end
