require 'spec_helper'

describe Frenetic::Middleware::HalJson do
  def process(body, content_type = nil, options = {}, status = 200)
    env = {
      body: body,
      request: options,
      response_headers: Faraday::Utils::Headers.new(headers),
      status: status
    }
    env[:response_headers]['content-type'] = content_type if content_type

    middleware.call env
  end

  let(:options) { Hash.new }
  let(:headers) { Hash.new }
  let(:middleware) do
    described_class.new(lambda do |env|
      Faraday::Response.new(env)
    end, options)
  end

  it 'does not change nil body' do
    expect(process(nil).body).to be_nil
  end

  it 'nullifies empty body' do
    expect(process('').body).to be_nil
  end

  context 'with a HAL+JSON body' do
    let(:body) do
      {
        'name' => 'My Name',
        '_embedded' => {
          'other_resource' => {
            'label' => 'My Label'
          }
        },
        '_links' => {
          'self' => {
            'href' => '/api/my_temp_resource/1'
          }
        }
      }.to_json
    end

    subject { process(body) }

    it 'parses the body' do
      expect(subject.body).to include 'name' => 'My Name'
    end
  end

  context 'with error response' do
    subject { process(error, nil, {}, status) }

    context 'from the server' do
      let(:status) { 500 }
      let(:error) do
        { 'status' => status.to_s, error:'500 Server Error' }.to_json
      end

      it 'raises an error' do
        expect{ subject }.to raise_error Frenetic::ServerError
      end
    end

    context 'cause by the client' do
      let(:status) { 404 }
      let(:error) do
        { 'status' => status.to_s, error:'404 Not Found' }.to_json
      end

      it 'raises an error' do
        expect{ subject }.to raise_error Frenetic::ClientError
      end
    end
  end
end
