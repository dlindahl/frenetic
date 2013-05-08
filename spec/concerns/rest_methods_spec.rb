require 'spec_helper'

describe Frenetic::RestMethods do
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
      before { @stubs.known_resource }

      it 'should return the instance' do
        expect(subject).to be_a MyTempResource
      end
    end

    context 'for an unknown instance' do
      before { @stubs.unknown_resource }

      it 'should raise an error' do
        expect{ subject }.to raise_error Frenetic::ClientError
      end
    end
  end
end