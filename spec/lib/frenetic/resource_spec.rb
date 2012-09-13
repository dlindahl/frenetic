describe Frenetic::Resource do

  let(:client) { Frenetic.new('url' => 'http://example.org') }

  let(:resource) { described_class.new }

  let(:description_stub) do
    Frenetic::HalJson::ResponseWrapper.new('resources' => { 'schema' => { 'resource' =>
      { 'properties' => { 'foo' => 2 } }
    } } )
  end

  subject { resource }

  context "created from a Hash" do
    let(:resource) { described_class.new( foo: 'bar' ) }

    it { should respond_to(:foo) }
    its(:links) { should be_a Hash }
    its(:links) { should be_empty }
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
    let(:resource_a) { described_class.new( wrapped_response ) }
    let(:resource_b) { described_class.new }

    before do
      client.stub(:description).and_return description_stub

      described_class.stub(:api).and_return client

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

      it { should_not respond_to(:foo) }
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
    context "with a block" do
      before { resource.class.api_client { client } }

      it "should reference the defined API client" do
        subject.class.api.should == client
      end
    end

    context "with an argument" do
      before { resource.class.api_client client }

      it "should reference the defined API client" do
        subject.class.api.should == client
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
        subject.should == description_stub.resources.schema.resource.properties
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