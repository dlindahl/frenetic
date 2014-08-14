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

  describe '#links' do
    before { @stubs.api_description }

    let(:_links) do
      {
        '_links' => { 'self' => { 'href' => '/api/self' }}
      }
    end

    subject { MyTempResource.new(_links).links }

    it 'returns the instances links' do
      expect(subject).to include 'self'
    end
  end

  describe '#member_url' do
    before { @stubs.api_description }

    subject { MyTempResource.new(_links).member_url }

    context 'with a link that matches the resource name' do
      let(:_links) do
        {
          '_links' => {
            'self' => { 'href' => '/api/self' },
            'my_temp_resource' => {
              'href' => '/api/my_temp_resource'
            }
          }
        }
      end

      it 'processes the link' do
        expect_any_instance_of(Frenetic::HypermediaLinkSet)
          .to receive(:href).with({}).and_call_original
        subject
      end

      it 'finds the appropriate link' do
        # Admittedly, this isn't the best test in the world, but I wanted to
        # ensure that the correct link is found out of the set
        expect(subject).to eq '/api/my_temp_resource'
      end
    end

    context 'with an implied self link' do
      let(:_links) do
        {
          '_links' => { 'self' => { 'href' => '/api/self' }}
        }
      end

      it 'processes the link' do
        expect_any_instance_of(Frenetic::HypermediaLinkSet)
          .to receive(:href).with({}).and_call_original
        subject
      end

      it 'returns the :self link' do
        # Admittedly, this isn't the best test in the world, but I wanted to
        # ensure that the correct link is found out of the set
        expect(subject).to eq '/api/self'
      end
    end
  end

  describe '.member_url' do
    let(:params) { { id:1 } }

    before { @stubs.api_description }

    subject { MyTempResource.member_url params }

    it 'processes the link' do
      expect_any_instance_of(Frenetic::HypermediaLinkSet)
        .to receive(:href).with( params ).and_call_original
      subject
    end
  end

  describe '.collection_url' do
    before { @stubs.api_description }

    subject { MyTempResource.collection_url }

    context 'for an unknown resource' do
      before do
        allow(MyTempResource)
          .to receive(:namespace)
            .and_return(Time.now.to_i.to_s)
      end

      it 'raises an error' do
        expect{subject}.to raise_error Frenetic::HypermediaError
      end
    end

    context 'for a known resource' do
      it 'processes the link' do
        expect_any_instance_of(Frenetic::HypermediaLinkSet)
          .to receive(:href).and_call_original
        subject
      end
    end
  end
end