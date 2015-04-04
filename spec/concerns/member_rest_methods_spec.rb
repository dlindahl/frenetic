require 'spec_helper'

describe Frenetic::MemberRestMethods do
  let(:test_cfg) { { url:'http://example.com/api' } }

  let(:my_temp_resource) do
    cfg = test_cfg

    Class.new(Frenetic::Resource) do
      api_client { Frenetic.new(cfg) }
    end
  end

  before do
    stub_const 'MyTempResource', my_temp_resource
    MyTempResource.send :include, described_class
  end

  describe '.find' do
    let(:params) { 1 }

    before { @stubs.api_description }

    subject { MyTempResource.find(params) }

    context 'for a known instance' do
      before { @stubs.known_instance }

      it 'returns the instance' do
        expect(subject).to be_a MyTempResource
      end

      context 'and a Hash argument' do
        subject { MyTempResource.find id:1 }

        it 'returns the instance' do
          expect(subject).to be_a MyTempResource
        end
      end
    end

    context 'for an unknown instance' do
      before { @stubs.unknown_instance }

      it 'raises an error' do
        expect{subject}.to raise_error Frenetic::ResourceNotFound, %q(Couldn't find MyTempResource with id=1)
      end

      context 'with an unparseable response' do
        before { @stubs.invalid_unknown_instance }

        it 'raises an error' do
          expect{subject}.to raise_error Frenetic::ResourceNotFound, %q(Couldn't find MyTempResource with id=1)
        end
      end
    end

    context 'that results in a client-level error' do
      before { @stubs.api_client_error }

      it 'raises an error' do
        expect{subject}.to raise_error Frenetic::ClientError, %q(422 Unprocessable Entity)
      end
    end

    context 'in test mode' do
      let(:test_cfg) { { url:'http://example.com/api', test_mode:true } }

      before do
        stub_const 'MyMockResource', Class.new(MyTempResource)
        MyMockResource.send :include, Frenetic::ResourceMockery
      end

      it 'returns a mock resource' do
        expect(subject).to be_an_instance_of MyMockResource
      end

      context 'with blank parameters' do
        let(:params) { {} }

        it 'raises an error' do
          expect{subject}.to raise_error Frenetic::ResourceNotFound, %q(Couldn't find MyTempResource without an ID)
        end
      end
    end
  end

  describe '.all' do
    before { @stubs.api_description }

    subject { MyTempResource.all }

    context 'for a known resource' do
      before { @stubs.known_resource }

      it 'returns a resource collection' do
        expect(subject).to be_an_instance_of Frenetic::ResourceCollection
      end

      it 'instantiates all resources in the collection' do
        expect(subject.first).to be_an_instance_of MyTempResource
      end
    end

    context 'in test mode' do
      let(:test_cfg) { { url:'http://example.com/api', test_mode:true } }

      it 'returns an empty collection' do
        expect(subject).to be_empty
      end
    end
  end
end
