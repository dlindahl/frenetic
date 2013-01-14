describe Frenetic::Configuration do
  let(:config) { { url:'http://example.org' } }

  let(:cache_cfg) do
    {
      metastore:     'foo',
      entitystore:   'bar'
    }
  end

  let(:instance) { described_class.new( config ) }

  subject { instance }

  it { should respond_to(:cache) }
  it { should respond_to(:url) }
  it { should respond_to(:username) }
  it { should respond_to(:password) }
  it { should respond_to(:headers) }
  it { should respond_to(:request) }
  it { should respond_to(:response) }
  it { should respond_to(:middleware) }

  describe '#attributes' do
    before { instance.use 'MyMiddleware' }

    subject { instance.attributes }

    it { should include(:cache) }
    it { should include(:url) }
    it { should include(:username) }
    it { should include(:password) }
    it { should include(:headers) }
    it { should include(:request) }
    it { should include(:response) }
    it { should_not include(:middleware) }

    it 'should validate the configuration' do
      instance.should_receive :validate!

      subject
    end

    context 'with string keys' do
      let(:config) { {'url' => 'https://example.org'} }

      it 'should symbolize the keys' do
        subject[:url].should == 'https://example.org'
      end
    end
  end

  describe '#headers' do
    let(:attrs) { instance.headers }

    context 'Accepts' do
      subject { attrs[:accept] }

      it { should == 'application/hal+json' }

      context 'with other specific headers' do
        before { config.merge!(headers:{foo:123} )}

        it { should == 'application/hal+json' }
      end

      context 'with a custom Accepts header' do
        before { config.merge!(headers:{'accept' => 'application/vnd.yoursite-v1.hal+json'} )}

        it { should == 'application/vnd.yoursite-v1.hal+json' }
      end
    end

    context 'User-Agent' do
      subject { attrs[:user_agent] }

      it { should match %r{Frenetic v\d+\.\d+\.\d+; .+\Z} }

      context 'with a custom value' do
        before { config.merge!( headers:{user_agent:'MyApp'}) }

        it { should match %r{\AMyApp \(Frenetic v\d+\.\d+\.\d+; .+\)\Z} }
      end
    end
  end

  describe '#cache' do
    before { config.merge!(cache:cache_cfg) }

    subject { instance.cache }

    it { should include(metastore:'foo') }
    it { should include(entitystore:'bar') }
    it { should include(ignore_headers:%w[Set-Cookie X-Content-Digest]) }

    context 'with custom ignore headers' do
      before { cache_cfg.merge!(ignore_headers:%w{Set-Cookie X-My-Header}) }

      it { should include(ignore_headers:%w[Set-Cookie X-My-Header X-Content-Digest]) }
    end
  end

  describe '#username' do
    subject { instance.username }

    before { config.merge!(api_key:'api_key') }

    it { should == 'api_key' }

    context 'and an App ID' do
      before { config.merge!(app_id:'app_id') }

      it { should == 'app_id' }
    end
  end

  describe '#password' do
    subject { instance.password }

    before { config.merge!(api_key:'api_key') }

    it { should be_nil }

    context 'and an App ID' do
      before { config.merge!(app_id:'app_id') }

      it { should == 'api_key' }
    end
  end

  describe '#initialize' do
    subject { instance.attributes }

    it { should be_a Hash }
    it { should_not be_empty }
  end

  describe '#validate!' do
    subject { instance.validate! }

    shared_examples_for 'a misconfigured instance' do
      it 'by raising an error when empty' do
        expect{ subject }.to raise_error Frenetic::ConfigurationError
      end
    end

    context ':url' do
      before { config.delete :url }

      it_should_behave_like 'a misconfigured instance'
    end

    context ':cache' do
      context 'with a missing :metastore' do
        before { config.merge!(cache:{}) }

        it_should_behave_like 'a misconfigured instance'
      end

      context 'with a missing :entitystore' do
        before { config.merge!(cache:{metastore:'store'}) }

        it_should_behave_like 'a misconfigured instance'
      end

      context 'with no missing properties' do
        before { config.merge!(cache:{metastore:'mstore',entitystore:'estore'}) }

        it 'should not raise an error' do
          expect{ subject }.to_not raise_error
        end
      end
    end
  end

  describe '#use' do
    before do
      stub_const 'MyMiddleware', Class.new

      instance.use MyMiddleware, foo:123
    end

    it 'should use the middleware' do
      subject.middleware.should include [ MyMiddleware, {foo:123} ]
    end
  end
end