describe Frenetic::Resource do

  @client = Frenetic.new('url' => 'http://example.org')

  let(:resource) { Frenetic::Resource.new }
  let(:description_stub) do
    Frenetic::HalJson::ResponseWrapper.new('resources' => { 'schema' => { 'resource' =>
      { 'properties' => { 'foo' => 2 } }
    } } )
  end

  subject { resource }

  context "created from a Hash" do
    let(:resource) { Frenetic::Resource.new( foo: 'bar' ) }

    it { should respond_to(:foo) }
    its(:links) { should be_empty }
  end

  context "created from a HAL-JSON response" do
    let(:api_response) do
      Frenetic::HalJson::ResponseWrapper.new(
        '_links' => {
          '_self' => { '_href' => 'bar' }
        },
        'foo' => 1,
        'bar' => 2,
        '_embedded' => {
          'baz' => 'resource'
        }
      )
    end
    let(:resource_a) { Frenetic::Resource.new( api_response ) }
    let(:resource_b) { Frenetic::Resource.new }

    before do
      @client.stubs(:description).returns( description_stub )

      Frenetic::Resource.stubs(:api).returns( @client )

      resource_a and resource_b
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
  end

  describe ".api_client" do
    context "with a block" do
      before { resource.class.api_client { @client } }

      it "should reference the defined API client" do
        subject.class.api.should == @client
      end
    end

    context "with an argument" do
      before { resource.class.api_client @client }

      it "should reference the defined API client" do
        subject.class.api.should == @client
      end
    end
  end

  describe ".schema" do
    subject { resource.class.schema }

    context "with a defined API Client" do
      before do
        @client.stubs(:description).returns( description_stub )

        resource.class.api_client @client
      end

      it "should return the schema for the specific resource" do
        subject.should == description_stub.resources.schema.resource.properties
      end
    end

    context "without a defined API Client" do
      before { Frenetic::Resource.stubs(:respond_to?).with(:api).returns( false ) }

      it "should raise an error" do
        expect { subject }.to raise_error(Frenetic::MissingAPIReference)
      end
    end
  end
end