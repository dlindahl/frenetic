describe Frenetic do
  let(:client) { Frenetic.new }

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
        config.is_a? Frenetic::Configuration
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