require 'spec_helper'

describe Frenetic do
  subject(:instance) { described_class.new }

  describe '#connection' do
    subject { instance.connection }

    it { should be_a Faraday::Connection }
  end

  describe '#get' do
    subject { instance.get '/foo' }

    it 'should delegate to Faraday' do
      instance.connection.should_receive :get

      subject
    end
  end

  describe '#put' do
    subject { instance.put '/foo' }

    it 'should delegate to Faraday' do
      instance.connection.should_receive :put

      subject
    end
  end

  describe '#post' do
    subject { instance.post '/foo' }

    it 'should delegate to Faraday' do
      instance.connection.should_receive :post

      subject
    end
  end

  describe '#delete' do
    subject { instance.delete '/foo' }

    it 'should delegate to Faraday' do
      instance.connection.should_receive :delete

      subject
    end
  end
end