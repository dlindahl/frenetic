require 'spec_helper'

describe Frenetic::Configuration do
  let(:cfg) { Hash.new }

  subject { described_class.new cfg }

  describe '#adapter' do
    subject { super().adapter }

    it 'defaults to Net::HTTP' do
      expect(subject).to eq :net_http
    end
  end

  describe '#attributes' do
    subject { super().attributes }

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

    subject { super().api_token }

    it 'returns the Api Token' do
      expect(subject).to eq 'API_TOKEN'
    end
  end

  describe '#cache' do
    subject { super().cache }

    context 'with a value of :rack' do
      let(:cfg) do
        { cache: :rack, url:'http://example.com' }
      end

      it 'returns Rack::Cache options' do
        expect(subject).to include metastore:'file:tmp/rack/meta/5ababd603b22780302dd8d83498e5172'
        expect(subject).to include entitystore:'file:tmp/rack/body/5ababd603b22780302dd8d83498e5172'
        expect(subject).to include ignore_headers:%w{Authorization Set-Cookie X-Content-Digest}
      end
    end
  end

  describe '#default_root_cache_age' do
    let(:cfg) do
      { default_root_cache_age:3600 }
    end

    subject { super().default_root_cache_age }

    it 'returns the cache age' do
      expect(subject).to eq 3600
    end
  end

  describe '#headers' do
    let(:cfg) do
      { headers:{ accept:'MIME', x_foo:'BAR' } }
    end

    subject { super().headers }

    it 'properly merges in nested header values' do
      expect(subject).to include :user_agent
      expect(subject).to include accept:'MIME'
      expect(subject).to include x_foo:'BAR'
    end

    context 'with a custom User-Agent' do
      let(:cfg) do
        { headers:{ user_agent:'Foo v1.1' } }
      end

      it 'appends the Frenentic User-Agent' do
        expect(subject[:user_agent]).to match %r{\AFoo v1.1 \(Frenetic v.[^;]*; [^)]*\)\Z}
      end
    end
  end

  describe '#password' do
    subject { super().password }

    context 'with a specifed Api key' do
      let(:cfg) do
        { api_key:'API_KEY' }
      end

      it 'returns the Api key' do
        expect(subject).to eq 'API_KEY'
      end
    end
  end

  describe '#ssl' do
    subject { super().ssl }

    it 'returns SSL options' do
      expect(subject).to include verify:true
    end
  end

  describe '#test_mode' do
    subject { super().test_mode }

    it 'returns FALSE' do
      expect(subject).to eq false
    end
  end

  describe '#url' do
    let(:cfg) do
      { url:'http://example.org' }
    end

    subject { super().url }

    it 'converts the value into an Addressable URI' do
      expect(subject).to be_an Addressable::URI
    end
  end

  describe '#username' do
    subject { super().username }

    context 'with a specifed App Id' do
      let(:cfg) do
        { app_id:'APP_ID' }
      end

      it 'returns the App ID' do
        expect(subject).to eq 'APP_ID'
      end
    end
  end
end