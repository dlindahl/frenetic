require 'spec_helper'

require 'frenetic/resource_mockery'

describe Frenetic::ResourceMockery do
  let(:my_mocked_resource) do
    Class.new(Frenetic::Resource) do
      def default_attributes
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

  describe '#properties' do
    subject { super().properties }

    it 'should return a hash of available properties' do
      subject.should include 'foo' => 'fixnum'
      subject.should include 'bar' => 'string'
    end
  end

  describe '#attributes' do
    subject { super().attributes }

    it 'should return a hash of the resources attributes' do
      subject.should include 'foo' => 1
      subject.should include 'bar' => 'baz'
      subject.should include 'qux' => 'qux'
    end
  end

  describe '#default_attributes' do
    it 'should allow implementors to specify sane defaults' do
      subject.qux.should == 'qux'
    end
  end
end