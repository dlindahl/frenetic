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

    it 'should return the instances links' do
      subject.should include 'self'
    end
  end

  describe '#member_url' do
    before { @stubs.api_description }

    subject { MyTempResource.new(_links).member_url params }

    let(:params) {}

    let(:_links) do
      {
        '_links' => {
          'self' => { 'href' => '/api/self' },
          'my_temp_resource' => {
            'href' => '/api/my_temp_resource/{id}', 'templated' => true
          }
        }
      }
    end

    context 'with a link that matches the resource name' do
      context 'and there are not enough parameters to satisfy the template' do
        it 'should raise an error' do
          expect{subject}.to raise_error Frenetic::LinkTemplateError
        end
      end

      context 'and enough parameters to satisfy the template' do
        let(:params) { { id:1 } }

        it 'should return the named link' do
          subject.should == '/api/my_temp_resource/1'
        end
      end
    end

    context 'with an implied self link' do
      let(:_links) do
        {
          '_links' => { 'self' => { 'href' => '/api/self' }}
        }
      end

      it 'should return the :self link' do
        subject.should == '/api/self'
      end
    end
  end

  describe '.member_url' do
    let(:args) {}

    subject { MyTempResource.member_url args }

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

        it 'should expand the URL template' do
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

  describe '.collection_url' do
    subject { MyTempResource.collection_url }

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
      it 'simply return the URL' do
        subject.should == '/api/my_temp_resources'
      end
    end
  end
end