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

  let(:collection_response) {
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
  }

  subject(:instance) { described_class.new(MyTempResource, collection_response) }

  it 'should know where the resources are located' do
    subject.collection_key.should == 'my_temp_resources'
  end

  it 'should know which resource it represents' do
    subject.resource_type.should == 'my_temp_resource'
  end

  it 'should extract the embedded resources' do
    subject.size.should == 2
  end

  it 'should parse the embedded resources' do
    subject.first.should be_a MyTempResource
  end

  it 'should be able to make API calls' do
    subject.api.should be_an_instance_of Frenetic
  end

  it 'should have links' do
    subject.links.should_not be_empty
  end

  describe '#get' do
    before { @stubs.known_resource }

    subject { super().get(1) }

    it 'should GET the full representation' do
      subject.should be_an_instance_of MyTempResource
    end
  end

end