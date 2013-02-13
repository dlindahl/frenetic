describe Frenetic::Resource do

  let(:client) { Frenetic.new(url:'http://example.org') }

  let(:resource) { MyResource.new }

  let(:other_resource) { MyOtherResource.new }

  let(:description_stub) do
    Frenetic::HalJson::ResponseWrapper.new('resources' => {
      'schema' => {
        'my_resource' => { 'properties' => { 'foo' => 'string' } },
        'my_other_resource' => { 'properties' => {} }
    } } )
  end

  before do
    client.stub(:description).and_return description_stub

    described_class.stub(:api).and_return client

    stub_const 'MyResource', Class.new(described_class)
    stub_const 'MyOtherResource', Class.new(described_class)
  end

  subject { resource }

  context "created from a Hash" do
    let(:resource) { MyResource.new( foo: 'bar' ) }

    it { should respond_to(:foo) }
    it { should respond_to(:foo=) }
    its(:links) { should be_a Hash }
    its(:links) { should be_empty }

    context 'other subclasses' do
      subject { other_resource }

      it { should_not respond_to(:foo) }
      it { should_not respond_to(:foo=) }
    end
  end

  context "created from a HAL-JSON response" do
    let(:api_response) do
      {
        '_links' => {
          '_self' => { '_href' => 'bar' }
        },
        'foo' => 1,
        'bar' => 2
      }
    end

    let(:wrapped_response) do
      Frenetic::HalJson::ResponseWrapper.new(api_response)
    end

    let(:resource_a) { MyResource.new( wrapped_response ) }

    let(:resource_b) { MyResource.new }

    before do
      resource_a && resource_b
    end

    context "initialized with data" do
      subject { resource_a }

      its(:foo) { should == 1 }
      it { should_not respond_to(:bar) }
      its(:links) { should_not be_empty }
    end

    context "intiailized in sequence without data" do
      subject { resource_b }

      it { should respond_to(:foo) }
      it { should_not respond_to(:bar) }
      its(:links) { should be_empty }
    end

    context "with embedded resources" do
      let(:api_response) do
        {
          '_links' => {
            '_self' => { '_href' => 'bar' }
          },
          'foo' => 1,
          '_embedded' => {
            'baz' => 'resource'
          }
        }
      end

      subject { resource_a }

      it { should respond_to(:baz) }
    end
  end

  describe ".api_client" do
    before do
      described_class.unstub! :api
    end

    subject { MyResource }

    context "with a block" do
      before { subject.api_client { client } }

      it "should reference the defined API client" do
        subject.api.should eq client

        MyOtherResource.should_not respond_to :api
      end
    end

    context "with an argument" do
      before { MyResource.api_client client }

      it "should reference the defined API client" do
        subject.api.should eq client

        MyOtherResource.should_not respond_to :api
      end
    end
  end

  describe ".schema" do
    subject { resource.class.schema }

    context "with a defined API Client" do
      before do
        client.stub(:description).and_return description_stub

        resource.class.api_client client
      end

      it "should return the schema for the specific resource" do
        subject.should == description_stub.resources.schema.my_resource.properties
      end
    end

    context "without a defined API Client" do
      before { described_class.stub(:respond_to?).with(:api).and_return false }

      it "should raise an error" do
        expect { subject }.to raise_error(Frenetic::MissingAPIReference)
      end
    end
  end
end