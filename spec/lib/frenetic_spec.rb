describe Frenetic do
  let(:client) { described_class.new }

  let(:config) { {
    url:     'http://example.org:5447/api',
    api_key: '1234567890',
    version: 'v1',
    response: {}
  } }

  before { Frenetic::Configuration.stub(:new).and_return config }

  subject { client }

  it { should respond_to(:description) }
  it { should respond_to(:connection) }
  it { should respond_to(:conn) }
  it { should respond_to(:get) }
  it { should respond_to(:put) }
  it { should respond_to(:post) }
  it { should respond_to(:delete) }

  its(:connection) { should be_a(Faraday::Connection) }

  it 'should accept a configuration block' do
    described_class.new( config ) do |cfg|
      cfg.should == config
    end
  end

  describe "#connection" do
    let(:connection) { client.connection }

    subject { client.connection }

    it { should be_a Faraday::Connection }

    it "should be created" do
      Faraday.should_receive( :new ).with do |cfg|
        cfg.has_key? :url
      end

      client
    end

    describe 'logger configuration' do
      before { config[:response][:use_logger] = true }

      subject { connection.builder.handlers.collect(&:name) }

      it { should include 'Faraday::Response::Logger' }
    end
  end
 
  describe "#description" do
    context "for a conforming API" do
      subject do
        VCR.use_cassette('description_success') do
          client.description
        end
      end

      it { should be_a( Frenetic::HalJson::ResponseWrapper ) }
    end

    context "with an unauthorized request" do
      let(:fetch!) do
        VCR.use_cassette('description_error_unauthorized') do
          client.description
        end
      end

      it "should raise an error" do
        expect{ fetch! }.to raise_error(Frenetic::InvalidAPIDescription)
      end
    end
  end

  describe "#reload!" do
    before do
      VCR.use_cassette('description_success') do
        client.description
      end

      client.reload!
    end

    it "should not have any non-Nil instance variables" do
      client.instance_variables.none? { |s| client.instance_variable_get(s).nil? }.should be_false
    end
  end

end