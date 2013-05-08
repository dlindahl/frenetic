require 'spec_helper'

describe Frenetic::HalLinked do
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

  describe '.get_url' do
    let(:args) {}

    subject { MyTempResource.get_url args }

    before { @stubs.api_description }

    context 'for an unknown resource' do
      before do
        MyTempResource.stub(:namespace).and_return Time.now.to_i.to_s
      end

      it 'should raise an error' do
        expect{ subject }.to raise_error Frenetic::HypermediaError
      end
    end

    context 'with a non-templated URL' do
      before do
        MyTempResource.stub(:namespace).and_return 'abstract_resource'
      end

      it 'simply return the URL' do
        subject.should == '/api/abstract_resource'
      end
    end

    context 'with a templated URL' do
      context 'and a non-Hash argument' do
        let(:args) { 1 }

        it 'should interpolate the URL' do
          subject.should == '/api/my_temp_resources/1'
        end
      end

      context 'with a Hash argument' do
        let(:args) { { id:1 } }

        it 'should interpolate the URL' do
          subject.should == '/api/my_temp_resources/1'
        end
      end
    end
  end
end