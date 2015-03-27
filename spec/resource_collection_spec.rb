require 'spec_helper'

describe Frenetic::ResourceCollection do
  let(:test_cfg) do
    {
      url:'http://example.com/api'
    }
  end

  let(:my_temp_resource) do
    cfg = test_cfg

    Class.new(Frenetic::Resource) do
      api_client { Frenetic.new(cfg) }
    end
  end

  before do
    stub_const 'MyTempResource', my_temp_resource
    @stubs.api_description
  end

  let(:collection_response) do
    {
      '_embedded' => {
        'my_temp_resources' => [
          { 'id' => 1, 'name' => 'First' },
          { 'id' => 2, 'name' => 'Last'  }
        ]
      },
      '_links' => {
        'self' => {
          'href' => '/api/my_temp_resources'
        },
        'my_temp_resource' => {
          'href' => '/api/my_temp_resources/{id}',
          'templated' => true
        }
      }
    }
  end

  subject(:instance) { described_class.new(MyTempResource, collection_response) }

  it 'knows where the resources are located' do
    expect(subject.collection_key).to eq 'my_temp_resources'
  end

  it 'knows which resource it represents' do
    expect(subject.resource_type).to eq 'my_temp_resource'
  end

  it 'extracts the embedded resources' do
    expect(subject.size).to eq 2
  end

  it 'parses the embedded resources' do
    expect(subject.first).to be_a MyTempResource
  end

  it 'is able to make API calls' do
    expect(subject.api).to be_an_instance_of Frenetic
  end

  it 'has links' do
    expect(subject.links).to_not be_empty
  end

  context 'for a non-embedded resource' do
    subject { described_class.new(MyTempResource) }

    it 'is empty' do
      expect(subject).to be_empty
    end
  end

  describe '#get' do
    before { @stubs.known_instance }

    subject { super().get(1) }

    it 'issues a GET the full representation' do
      expect(subject).to be_an_instance_of MyTempResource
    end
  end
end
