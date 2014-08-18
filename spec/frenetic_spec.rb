require 'spec_helper'

describe Frenetic do
  let(:url) { 'http://example.com/api' }
  let(:test_cfg) { { url:url } }

  subject(:instance) { described_class.new(test_cfg) }

  describe '.config' do
    subject { described_class.config }

    it 'includes expected options' do
      expect(subject).to include adapter: Faraday.default_adapter
      expect(subject).to include :api_token
      expect(subject).to include cache:false
      expect(subject).to include :default_root_cache_age
      expect(subject).to include headers:kind_of(Hash)
      expect(subject).to include middleware:[]
      expect(subject).to include :password
      expect(subject).to include ssl:{verify:true}
      expect(subject).to include test_mode:false
      expect(subject).to include :url
      expect(subject).to include :username
    end
  end

  describe '#config' do
    subject { super().config }

    it 'includes non-default instance values' do
      expect(subject.url).to eq url
    end

    it 'does not override the default class values' do
      expect(subject.url).to_not eq described_class.config.url
    end
  end

  describe '#configure' do
    subject { instance.configure {|c| } }

    it 'resets the Connection' do
      prev_connection = instance.connection
      subject
      expect(instance.connection).to_not eq prev_connection
    end
  end

  describe '#connection' do
    subject { super().connection }

    it 'returns a Connection' do
      expect(subject).to be_a Frenetic::Connection
    end
  end

  # describe '#connection' do
  #   subject { super().connection }

  #   it 'returns a Faraday Connection' do
  #     expect(subject).to be_a Faraday::Connection
  #   end

  #   context 'when Frenetic is initialized with a block' do
  #     subject do
  #       builder = nil
  #       described_class.new(test_cfg) do |b|
  #         builder = b
  #       end.connection
  #       builder
  #     end

  #     it 'yields the Faraday builder to the block argument' do
  #       expect(subject).to be_a Faraday::Connection
  #     end
  #   end

  #   describe 'middleware' do
  #     subject { super().builder.handlers }

  #     context 'configured with a :username' do
  #       let(:test_cfg) { super().merge username:'foo' }

  #       it 'includes Basic Auth middleware' do
  #         expect(subject).to include Faraday::Request::BasicAuthentication
  #       end
  #     end

  #     context 'configured with a :api_token' do
  #       let(:test_cfg) { super().merge api_token:'API_TOKEN' }

  #       it 'includes Token Authentication middleware' do
  #         expect(subject).to include Faraday::Request::TokenAuthentication
  #       end
  #     end

  #     context 'configured to use Rack::Cache' do
  #       let(:test_cfg) { super().merge cache: :rack }

  #       it 'includes Rack middleware' do
  #         expect(subject).to include FaradayMiddleware::RackCompatible
  #       end
  #     end
  #   end
  # end

  # describe '#description' do
  #   subject { super().description }

  #   context 'with a URL that returns a' do
  #     context 'valid response' do
  #       before { @stubs.api_description }

  #       it 'includes meta Hypermedia properties' do
  #         expect(subject).to include '_embedded'
  #         expect(subject).to include '_links'
  #       end
  #     end

  #     context 'server error' do
  #       before { @stubs.api_server_error }

  #       it 'raises an error' do
  #         expect{subject}.to raise_error Frenetic::ServerParsingError
  #       end
  #     end

  #     context 'client error' do
  #       before { @stubs.api_client_error :json }

  #       it 'raises an error' do
  #         expect{subject}.to raise_error Frenetic::ClientError
  #       end
  #     end

  #     context 'JSON parsing error' do
  #       context 'for an otherwise successful response' do
  #         before { @stubs.api_html_response }

  #         it 'raises an error' do
  #           expect{subject}.to raise_error Frenetic::UnknownParsingError
  #         end
  #       end

  #       context 'for a server error' do
  #         before { @stubs.api_server_error :text }

  #         it 'raises an error' do
  #           expect{subject}.to raise_error Frenetic::ServerParsingError
  #         end
  #       end

  #       context 'for a client error' do
  #         before { @stubs.api_client_error :text }

  #         it 'raises an error' do
  #           expect{subject}.to raise_error Frenetic::ClientParsingError
  #         end
  #       end
  #     end
  #   end
  # end

  # describe '.schema' do
  #   before { @stubs.api_description }

  #   subject { super().schema }

  #   it 'includes a list of defined resources' do
  #     expect(subject).to include 'my_temp_resource'
  #   end
  # end

  # describe '#get' do
  #   subject { super().get '/foo' }

  #   it 'delegates to Faraday' do
  #     allow(instance.connection).to receive(:get)
  #     subject
  #     expect(instance.connection).to have_received(:get)
  #   end
  # end

  # describe '#put' do
  #   subject { super().put '/foo' }

  #   it 'delegates to Faraday' do
  #     allow(instance.connection).to receive(:put)
  #     subject
  #     expect(instance.connection).to have_received(:put)
  #   end
  # end

  # describe '#patch' do
  #   subject { super().patch '/foo' }

  #   it 'delegates to Faraday' do
  #     allow(instance.connection).to receive(:patch)
  #     subject
  #     expect(instance.connection).to have_received(:patch)
  #   end
  # end

  # describe '#head' do
  #   subject { instance.head '/foo' }

  #   it 'delegates to Faraday' do
  #     allow(instance.connection).to receive(:head)
  #     subject
  #     expect(instance.connection).to have_received(:head)
  #   end
  # end

  # describe '#options' do
  #   subject { instance.options '/foo' }

  #   it 'delegates to Faraday' do
  #     allow(instance.connection).to receive(:options)
  #     subject
  #     expect(instance.connection).to have_received(:options)
  #   end
  # end

  # describe '#post' do
  #   subject { super().post '/foo' }

  #   it 'delegates to Faraday' do
  #     allow(instance.connection).to receive(:post)
  #     subject
  #     expect(instance.connection).to have_received(:post)
  #   end
  # end

  # describe '#delete' do
  #   subject { super().delete '/foo' }

  #   it 'delegates to Faraday' do
  #     allow(instance.connection).to receive(:delete)
  #     subject
  #     expect(instance.connection).to have_received(:delete)
  #   end
  # end
end