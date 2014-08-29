require 'spec_helper'

require 'frenetic/resource_mockery'

describe Frenetic::ResourceMockery do
  let(:my_temp_resource) do
    Class.new(Frenetic::Resource)
  end

  let(:my_mocked_resource) do
    Class.new(my_temp_resource) do
      def self.default_attributes
        { qux:'qux' }
      end
    end
  end

  before do
    stub_const 'MyNamespace::MyMockedResource', my_mocked_resource
    MyNamespace::MyMockedResource.send :include, described_class
  end

  let(:params) { { foo:1, bar:'baz' } }

  subject { MyNamespace::MyMockedResource.new params }

  it 'violates some basic CS principles by telling the parent-class of its existence' do
    expect(my_temp_resource.instance_variables).to include :@mock_class
  end

  describe '#properties' do
    subject { super().properties }

    it 'returns a hash of available properties' do
      expect(subject).to include 'foo' => 'fixnum'
      expect(subject).to include 'bar' => 'string'
    end
  end

  describe '#attributes' do
    subject { super().attributes }

    it 'returns a hash of the resources attributes' do
      expect(subject).to include 'foo' => 1
      expect(subject).to include 'bar' => 'baz'
      expect(subject).to include 'qux' => 'qux'
    end
  end

  describe '.default_attributes' do
    let(:my_mocked_resource) { Class.new(my_temp_resource) }

    subject { MyNamespace::MyMockedResource.default_attributes }

    it 'allows implementors to specify sane defaults' do
      expect(subject).to eq Hash.new
    end
  end

  describe '#default_attributes' do
    let(:my_mocked_resource) { Class.new(my_temp_resource) }

    subject { MyNamespace::MyMockedResource.new.default_attributes }

    it 'proxies to the class method' do
      expect(subject).to eq Hash.new
    end
  end
end