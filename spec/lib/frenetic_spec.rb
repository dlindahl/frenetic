describe Frenetic do
  let(:client) { Frenetic.new }
  let(:config) { {
    :url     => 'http://example.org:5447/api',
    :api_key => '1234567890',
    :version => 'v1'
  } }

  before { Frenetic::Configuration.stubs(:new).returns(config) }

  subject { client }

  it { should respond_to(:schema) }
  it { should respond_to(:connection) }
  it { should respond_to(:conn) }
  it { should respond_to(:get) }
  it { should respond_to(:put) }
  it { should respond_to(:post) }
  it { should respond_to(:delete) }

  its(:connection) { should be_a(Faraday::Connection) }

  describe "#connection" do
    before do
      faraday_stub = Faraday.new
      Faraday.stubs(:new).returns( faraday_stub )

      client
    end

    subject { client.connection }

    it { should be_a(Faraday::Connection) }

    it "should be created" do
      Faraday.should have_received(:new).with() { |config|
        config.has_key? :url
      }
    end
  end
 
  describe "#schema" do
    subject do
      VCR.use_cassette('schema_success') do
        client.schema
      end
    end

    it { should be_a( Frenetic::HalJson::ResponseWrapper ) }
  end

end