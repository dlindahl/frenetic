describe Frenetic::Configuration do
  let(:cfg) { Hash.new }

  subject(:instance) { described_class.new cfg }

  describe '#adapter' do
    subject { instance.adapter }

    it 'defaults to Net::HTTP' do
      expect(subject).to eq :net_http
    end
  end

  describe '#attributes' do
    subject { instance.attributes }

    it 'includes expected attributes' do
      expect(subject).to include :adapter
      expect(subject).to include :api_token
      expect(subject).to include :cache
      expect(subject).to include :default_root_cache_age
      expect(subject).to include :headers
      expect(subject).to include :password
      expect(subject).to include :ssl
      expect(subject).to include :test_mode
      expect(subject).to include :url
      expect(subject).to include :username
    end
  end

  describe '#api_token' do
    let(:cfg) do
      { api_token:'API_TOKEN' }
    end

    subject { instance.api_token }

    it { should == 'API_TOKEN' }
  end

  describe '#cache' do
    subject { instance.cache }

    context 'with a value of :rack' do
      let(:cfg) do
        { cache: :rack, url:'http://example.com' }
      end

      it 'should return Rack::Cache options' do
        subject.should include metastore:'file:tmp/rack/meta/5ababd603b22780302dd8d83498e5172'
        subject.should include entitystore:'file:tmp/rack/body/5ababd603b22780302dd8d83498e5172'
        subject.should include ignore_headers:%w{Authorization Set-Cookie X-Content-Digest}
      end
    end
  end

  describe '#default_root_cache_age' do
    let(:cfg) do
      { default_root_cache_age:3600 }
    end

    subject { instance.default_root_cache_age }

    it { should == 3600 }
  end

  describe '#headers' do
    let(:cfg) do
      { headers:{ accept:'MIME', x_foo:'BAR' } }
    end

    subject { instance.headers }

    it 'should properly merge in nested header values' do
      subject.should include :user_agent
      subject.should include accept:'MIME'
      subject.should include x_foo:'BAR'
    end

    context 'with a custom User-Agent' do
      let(:cfg) do
        { headers:{ user_agent:'Foo v1.1' } }
      end

      it 'should append the Frenentic User-Agent' do
        subject[:user_agent].should match %r{\AFoo v1.1 \(Frenetic v.[^;]*; [^)]*\)\Z}
      end
    end
  end

  describe '#password' do
    subject { instance.password }

    context 'with a specifed Api key' do
      let(:cfg) do
        { api_key:'API_KEY' }
      end

      it { should == 'API_KEY' }
    end
  end

  describe '#ssl' do
    subject { instance.ssl }

    it { should include verify:true }
  end

  describe '#test_mode' do
    subject { instance.test_mode }

    it { should be_falsey }
  end

  describe '#url' do
    let(:cfg) do
      { url:'http://example.org' }
    end

    subject { instance.url }

    it { should be_a Addressable::URI }
  end

  describe '#username' do
    subject { instance.username }

    context 'with a specifed App Id' do
      let(:cfg) do
        { app_id:'APP_ID' }
      end

      it { should == 'APP_ID' }
    end
  end
end