describe Frenetic do
  let(:config) do
    {
      url:     'http://example.org:5447/api',
      api_key: '1234567890',
      version: 'v1',
      response: {}
    }
  end

  let(:client) { described_class.new(config) }

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
      cfg.should be_a described_class::Configuration
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

    describe 'middleware initialization' do
      before { stub_const 'MyMiddleware', Class.new }

      let(:client) do
        described_class.new(config) do |cfg|
          cfg.use MyMiddleware, foo:123
        end
      end

      subject { connection.builder.handlers }

      it 'should add the middleware to the connection' do
        subject.should include MyMiddleware
      end
    end

    describe 'Faraday adapter' do
      subject { connection.builder.handlers }

      context 'by default' do
        it 'should be :patron' do
          subject.should include Faraday::Adapter::NetHttp
        end
      end

      context 'when explicitly set' do
        before do
          config.merge! adapter: :patron
        end

        it 'should use the specified adapter' do
          subject.should include Faraday::Adapter::Patron
        end
      end
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