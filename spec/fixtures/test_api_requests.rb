require 'json'

# rubocop:disable Metrics/ClassLength
class HttpStubs
  def initialize(rspec)
    @rspec = rspec
  end

  def defaults
    {
      status:  200,
      headers: { 'Content-Type' => 'application/json' },
      body:    {}
    }
  end

  def response(params = {})
    defs = defaults.dup
    headers = params.delete :headers

    defs[:headers].merge! headers || {}

    defs.merge(params).tap do |p|
      p[:body] = p[:body].to_json
    end
  end

  def api_html_response
    @rspec.stub_request(:any, 'example.com/api')
      .to_return response(body:'Non-JSON response', status:200)
  end

  def api_error(type: :json, body: 'Not Found', status: 404, url: 'example.com/api')
    body = "#{status} #{body}"
    body = { 'error' => body } if type == :json

    @rspec.stub_request(:get, url)
      .to_return response(body:body, status:status.to_i)
  end

  def api_description
    @rspec.stub_request(:any, 'example.com/api')
      .to_return response(body:schema, headers:{ 'Cache-Control' => 'max-age=3600, public' })
  end

  def unknown_instance
    @rspec.stub_request(:get, 'example.com/api/my_temp_resources/1')
      .to_return response(body:{ 'error' => '404 Not Found' }, status:404)
  end

  def invalid_unknown_instance
    @rspec.stub_request(:get, 'example.com/api/my_temp_resources/1')
      .to_return response(body:'Unparseable Not Found', status:404)
  end

  def known_instance
    @rspec.stub_request(:get, 'example.com/api/my_temp_resources/1')
      .to_return response(body:{ 'name' => 'Resource Name' })
  end

  def known_resource
    @rspec.stub_request(:get, 'example.com/api/my_temp_resources')
      .to_return response(
        body: {
          '_embedded' => {
            'my_temp_resources' => [
              persisted_resource
            ]
          }
        }
      )
  end

  def filtered_resource
    @rspec.stub_request(:get, 'example.com/api/my_filtered_resources/filters/bar')
      .to_return response(
        body: {
          '_embedded' => {
            'my_filtered_resources' => [
              persisted_resource
            ]
          }
        }
      )
  end

  def valid_created_resource
    @rspec.stub_request(:post, 'example.com/api/my_temp_resources/')
      .to_return response(
        body: persisted_resource
      )
  end

  def invalid_created_resource
    @rspec.stub_request(:post, 'example.com/api/my_temp_resources/')
      .to_return response(
        status: 422,
        body: persisted_resource.merge(
          'errors' => {
            'name' => ['cannot be blank', 'must be a name'],
            'base' => ['cannot be valid']
          }
        )
      )
  end

  # rubocop:disable Metrics/MethodLength
  def schema
    {
      _embedded: {
        schema: {
          my_temp_resource: {
            description: 'Humanized resource description',
            properties: {
              id:   'number',
              name: 'string'
            }
          },
          my_filtered_resource: {
            description: 'Humanized resource description',
            properties: {
              id:   'number',
              name: 'string'
            }
          },
          abstract_resource: {
            description: 'A random thing',
            properties: {
              id:    'number',
              genus: 'string'
            }
          }
        }
      },
      _links: {
        schema: {
          href: '/api/schema'
        },
        my_temp_resources: {
          href: '/api/my_temp_resources'
        },
        my_filtered_resources: {
          href: '/api/my_filtered_resources/filters/{filter}',
          templated: true
        },
        my_temp_resource: {
          href: '/api/my_temp_resources/{id}',
          templated: true
        },
        abstract_resource: {
          href: '/api/abstract_resource'
        }
      }
    }
  end
  # rubocop:enable Metrics/MethodLength

  def persisted_resource(params = {})
    id = params.fetch('id', 1)
    {
      'id' => id,
      'name' => 'Resource Name',
      '_links' => {
        'self' => {
          'href' => "/api/my_temp_resources/#{id}"
        }
      }
    }.merge!(params)
  end
end
# rubocop:enable Metrics/ClassLength

RSpec.configure do |c|
  c.before :all do
    @stubs = HttpStubs.new(self)
  end
end
