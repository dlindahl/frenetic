require 'spec_helper'

describe Frenetic::Related do
  let(:success) { true }

  let(:response) do
    res = Struct.new(:body, :success?)
    res.new({
      'id' => 99,
      'foo' => 'bar'
    }, success)
  end

  let(:api_stub) { double('ApiDouble', get: response).as_null_object }

  let(:related_resource) do
    Class.new do
      attr_reader :id

      def initialize(attrs = {})
        @id = attrs.fetch('id')
      end
    end
  end

  let(:my_temp_resource) do
    Class.new do
      def initialize(attrs = {})
        @attrs = attrs
      end

      def api
        self.class.class_variable_get('@@_api_stub')
      end

      def links
        @attrs['_links']
      end

      def self.find_resource_class(*args)
        RelatedResource
      end
    end
  end

  let(:params) do
    {
      '_links' => {
        'self' => {},
        'related_resource' => {
          'href' => '/related_resource'
        }
      }
    }
  end

  before do
    stub_const('MyTempResource', my_temp_resource)
    stub_const('RelatedResource', related_resource)
    MyTempResource.class_variable_set('@@_api_stub', api_stub)
    MyTempResource.send(:include, described_class)
  end

  subject(:instance) { MyTempResource.new(params) }

  describe '#extract_related_resources' do
    subject { super().extract_related_resources }

    it 'builds a relation map' do
      subject
      expect(instance.send(:relations)).to_not be_empty
    end

    it 'does not extract self-referential resources' do
      subject
      expect(instance.send(:relations)).to_not include 'self'
    end
  end

  describe '#fetch_related_resource' do
    let(:relation) { 'related_resource' }

    let(:props) do
      {
        'id' => 99
      }
    end

    subject { super().fetch_related_resource(relation, props) }

    it 'returns the instantiated related resource instance' do
      expect(subject).to be_a RelatedResource
      expect(subject.id).to eql 99
    end

    context 'for an unsuccessul resource request' do
      let(:success) { false }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'with an unknown resource instance' do
      let(:exception) do
        Frenetic::ClientError.new(status: 404)
      end

      before do
        allow(api_stub).to receive(:get).and_raise(exception)
      end

      it 'raises an error' do
        expect{subject}.to raise_error(Frenetic::ResourceNotFound)
      end
    end
  end
end
