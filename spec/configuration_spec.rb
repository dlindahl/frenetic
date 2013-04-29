describe Frenetic::Configuration do
  let(:cfg) { Hash.new }

  subject(:instance) { described_class.new cfg }

  describe '#adapter' do
    subject { instance.adapter }

    it { should == :net_http }
  end

  describe '#attributes' do
    subject { instance.attributes }

    it { should include :adapter }
    it { should include :api_token }
    it { should include :cache }
    it { should include :headers }
    it { should include :password }
    it { should include :url }
    it { should include :username }
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
        { cache: :rack }
      end

      it 'should return Rack::Cache options' do
        subject.should include metastore:'file:tmp/rack/meta'
        subject.should include entitystore:'file:tmp/rack/body'
        subject.should include ignore_headers:%w{Authorization Set-Cookie X-Content-Digest}
      end
    end
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

  describe '#url' do
    let(:cfg) do
      { url:'http://example.org' }
    end

    subject { instance.url }

    it { should be_a Addressable::URI }

    its(:to_s) { should == 'http://example.org' }
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