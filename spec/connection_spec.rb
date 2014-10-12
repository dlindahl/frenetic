require 'spec_helper'

describe Frenetic::Connection do
  let(:url) { 'http://example.com' }
  let(:cfg) do
    {
      adapter: :net_http,
      url: url
    }
  end

  subject(:instance) { described_class.new(cfg) }

  describe '#initialize?' do
    subject { super().valid? }

    context 'with an invalid configuration' do
      let(:url) { nil }

      it 'raises an error' do
        expect{subject}.to raise_error Frenetic::ConfigError, %r{Url must be present}
      end
    end

    context 'with a valid configuration' do
      let(:url) { 'http://example.com' }

      it 'does not raise an error' do
        expect{subject}.to_not raise_error
      end
    end
  end

  describe '#process_config' do
    subject { super().process_config(url:url) }

    it 'returns a Faraday builder-compatible config' do
      expect(subject[0]).to be_a Hash
    end

    it 'returns a Faraday::Connection-compatible config' do
      expect(subject[1]).to include :url
    end

    context 'with specific port' do
      let(:url) { 'https://example.com:8443' }
      it 'converts URLs to URIs' do
        expect(subject[1]).to include url:kind_of(Addressable::URI)
        expect(subject[1][:url].port).to eq(8443)
      end
    end

    context 'with no specific port' do
      let(:url) { 'https://example.com' }
      it 'converts URLs to URIs with port inferred from scheme' do
        expect(subject[1]).to include url:kind_of(Addressable::URI)
        expect(subject[1][:url].port).to eq(443)
      end
    end
  end

  describe '#configure_authentication' do
    let(:builder) { double('FaradayBuilder', request:true) }

    subject { super().configure_authentication(builder) }

    context 'with no authentication credentials' do
      it 'does not use any authentication middleware' do
        subject
        expect(builder).to_not have_received(:request)
      end
    end

    context 'with Basic Auth credentials' do
      let(:cfg) { super().merge(username:'un', password:'pw') }

      it 'uses the Basic Auth middleware' do
        subject
        expect(builder).to have_received(:request).with(:basic_auth, 'un', 'pw')
      end
    end

    context 'with Basic Auth credentials' do
      let(:cfg) { super().merge(api_token:'abc123') }

      it 'uses the Basic Auth middleware' do
        subject
        expect(builder).to have_received(:request).with(:token_auth, 'abc123')
      end
    end
  end

  describe '#configure_cache' do
    let(:builder) { double('FaradayBuilder', use:true) }

    subject { super().configure_cache(builder) }

    context 'with no cache settings' do
      it 'does not use any caching middleware' do
        subject
        expect(builder).to_not have_received(:use)
      end
    end

    context 'with :rack' do
      let(:cfg) { super().merge(cache: :rack) }

      it 'uses the Rack::Compatible caching middleware' do
        subject
        expect(builder).to have_received(:use).with(
          FaradayMiddleware::RackCompatible,
          Rack::Cache::Context,
          hash_including(
            :metastore,
            :entitystore,
            :ignore_headers
          )
        )
      end
    end

    context 'with :rails' do
      let(:cfg) { super().merge(cache: :rails) }
      let(:rails) { double('Rails').as_null_object }

      before { stub_const 'Rails', rails }

      it 'uses the HttpCache caching middleware' do
        subject
        expect(builder).to have_received(:use).with(
          Faraday::HttpCache,
          hash_including(:store)
        )
      end
    end
  end

  describe '#configure_adapter' do
    let(:builder) { double('FaradayBuilder', adapter:true) }
    let(:cfg) { super().merge(adapter: :patron) }

    subject { super().configure_adapter(builder) }

    it 'uses the specified adapter' do
      subject
      expect(builder).to have_received(:adapter).with(:patron)
    end
  end
end
