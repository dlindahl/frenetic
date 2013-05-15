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
    before { @stubs.api_description }

    subject { MyTempResource.find 1 }

    context 'for a known instance' do
      before { @stubs.known_instance }

      it 'should return the instance' do
        expect(subject).to be_a MyTempResource
      end
    end

    context 'for an unknown instance' do
      before { @stubs.unknown_instance }

      it 'should raise an error' do
        expect{ subject }.to raise_error Frenetic::ClientError
      end
    end
  end

  describe '.all' do
    before { @stubs.api_description }

    subject { MyTempResource.all }

    context 'for a known resource' do
      before { @stubs.known_resource }

      it 'should return a resource collection' do
        expect(subject).to be_an_instance_of Frenetic::ResourceCollection
      end

      it 'should instantiate all resources in the collection' do
        expect(subject.first).to be_an_instance_of MyTempResource
      end
    end
  end
end