require 'spec_helper'

describe Distant::Base do
  before :all do
    Distant.configure do |config|
      config.base_uri = 'https://www.example.com/api/v0'
    end
    class Distant::BaseTest < Distant::Base
      attr_accessor :id, :name
      has_many :sub_tests, '/base/tests/:id/sub_tests'

      translate do
        from_hash do |hash|
          recursive_underscore(hash)
        end
        to_hash do |obj|
          {
            id: obj.id,
            fooId: obj.foo_id,
          }
        end
      end

    end

    class Distant::SubTest < Distant::Base
      attr_accessor :id, :base_test_id
      belongs_to :base_test, ''
    end
  end
  describe '.path_closure_generator(route)' do
    context 'when the route has' do
      context 'no variables' do
        before do
          @route = '/foo/bar'
        end
        context 'the closure returned' do
          before do
            @closure = Distant::BaseTest.path_closure_generator(@route)
          end
          it 'accepts no arguments' do
            expect{@closure.call()}.not_to raise_error
          end
        end
      end
      context 'one variable' do
        before do
          @route = '/foo/:id'
        end
        context 'the closure returned' do
          before do
            @closure = Distant::BaseTest.path_closure_generator(@route)
          end
          it 'accepts one corresponding argument' do
            expect{@closure.call(id: 123)}.not_to raise_error
            expect{@closure.call(blah: 123)}.to raise_error ArgumentError
          end
        end
      end
      context 'multiple variables' do
        before do
          @route = '/foo/:id/:bar_id'
        end
        context 'the closure returned' do
          before do
            @closure = Distant::BaseTest.path_closure_generator(@route)
          end
          it 'accepts all corresponding arguments' do
            expect{@closure.call(id: 123, bar_id: 456)}.not_to raise_error
            expect{@closure.call(id: 123)}.to raise_error ArgumentError
          end
        end
      end
    end
  end

  describe '#connection' do
    before do
      @obj = Distant::BaseTest.new
    end
    it 'calls the eponymous static method' do
      expect(@obj.class).to receive(:connection)
      @obj.connection
    end
  end

  describe '.connection' do
    context 'when called' do
      context 'the first time' do
        before do
          expect(Distant::Connection).to receive(:new).exactly(1).times
        end
        it 'returns a new Distant::Connection' do
          Distant::BaseTest.connection
        end
      end
      context 'subsequent times' do
        before do
          expect(Distant::Connection).to receive(:new).exactly(1).times.and_call_original
        end
        it 'returns the same Distant::Connection' do
          first_connection = Distant::BaseTest.connection
          expect(first_connection).to eq Distant::BaseTest.connection
        end
      end
    end
  end

  describe '.get(name, route)' do
    before do
      @route = '/base/tests'
      @single_route = '/base/tests/:id'
      Distant::BaseTest.get :all, @route
      Distant::BaseTest.get :find, @single_route
    end
    it 'creates a static method named correctly' do
      expect(Distant::BaseTest).to respond_to :all
    end
    context 'when the method created for a collection is called' do
      before do
        expect(Distant::BaseTest).to receive(:preprocess_response){ [{id: 123}] }
      end
      it 'makes a GET request with the correct route' do
        expect_any_instance_of(Distant::Connection).to receive(:get).with(@route, {})
        # Finally:
        Distant::BaseTest.all
      end
    end
    context 'when the method created for a single object is called' do
      before do
        expect(Distant::BaseTest).to receive(:preprocess_response){ {id: 123} }
      end
      it 'makes a GET request with the correct route' do
        expect_any_instance_of(Distant::Connection).to receive(:get).with(@single_route.gsub(':id', '123'), {})
        # Finally:
        Distant::BaseTest.find(id: 123)
      end
    end
  end

  describe '.has_many(plural, route)' do
    before do
      @route = '/base/:id/tests'
      Distant::BaseTest.has_many :sub_tests, @route
    end
    it 'creates an instance method named after the plural collection' do
      expect(Distant::BaseTest.new).to respond_to :sub_tests
    end
    context 'when the plural instance method is called' do
      before do
        expect(Distant::BaseTest).to receive(:preprocess_response){ [{base_test_id: 123, id: 456}]}
      end
      it 'makes a GET request with the correct route' do
        expect_any_instance_of(Distant::Connection).to receive(:get).with('/base/123/tests', {})
        result = Distant::BaseTest.new(id: 123).sub_tests
        expect(result.first).to be_a Distant::SubTest
      end
    end
  end

  describe '.belongs_to(singular, route)' do
    before do
      @route = '/base/:id'
      Distant::SubTest.belongs_to :base_test, @route
    end
    it 'creates an instance method named after the plural collection' do
      expect(Distant::SubTest.new).to respond_to :base_test
    end
    context 'when the  instance method is called' do
      before do
        expect(Distant::SubTest).to receive(:preprocess_response){ {id: 123, name: 'foo'}}
      end
      it 'makes a GET request with the correct route' do
        expect_any_instance_of(Distant::Connection).to receive(:get).with('/base/123', {})
        result = Distant::SubTest.new(id: 456, base_test_id: 123).base_test
        expect(result).to be_a Distant::BaseTest
      end
    end
  end

  describe '.preprocess_response(response)' do
    context 'when the response' do
      context 'fails' do
        before do
          @response = double('response')
          expect(@response).to receive(:code){ 400 }
        end
        it 'raises an exception' do
          expect{Distant::BaseTest.preprocess_response(@response)}.to raise_error Distant::ApiError
        end
      end
      context 'succeeds' do
        before do
          @response = double('response')
          expect(@response).to receive(:code){ 200 }
        end
        context 'and the response' do
          context 'is valid JSON' do
            before do
              @response_data = [
                {id: 123, name: 'Test'},
                {fooId: 456, nickName: 'Testy McTesterson'}
              ]
              @expected_data = [
                {id: 123, name: 'Test'},
                {foo_id: 456, nick_name: 'Testy McTesterson'}
              ]
              expect(@response).to receive(:body){ @response_data.to_json }
            end
            it 'returns the parsed JSON response' do
              expect(Distant::BaseTest.preprocess_response(@response)).to eq @expected_data
            end
          end
          context 'is not valid JSON' do
            before do
              expect(@response).to receive(:body){ '<html>wat?</html>' }
            end
            it 'raises an exception' do
              expect{Distant::BaseTest.preprocess_response(@response)}.to raise_error JSON::ParserError
            end
          end
        end
      end
    end
  end

  describe '#has_many?(other_things)' do
    context 'when the thing' do
      context 'does have many other_things' do
        it 'returns true' do
          expect(Distant::BaseTest.new.has_many?(:sub_tests)).to be_truthy
        end
      end
      context 'does not have many other_things' do
        it 'returns false' do
          expect(Distant::BaseTest.new.has_many?(:sdf987sd98f7)).to be_falsey
        end
      end
    end
  end

  describe '#belongs_to?(other_thing)' do
    context 'when the thing' do
      context 'does belong to other_thing' do
        it 'returns true' do
          expect(Distant::SubTest.new.belongs_to?(:base_test)).to be_truthy
        end
      end
      context 'does not have many other_things' do
        it 'returns false' do
          expect(Distant::SubTest.new.belongs_to?(:kjh234kjh23kj4h)).to be_falsey
        end
      end
    end
  end
end
