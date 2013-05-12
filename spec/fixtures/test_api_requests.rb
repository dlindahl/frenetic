require 'json'

class HttpStubs

  def initialize( rspec )
    @rspec = rspec
  end

  def defaults
    {
      status:  200,
      headers: { 'Content-Type'=>'application/json' },
      body:    {}
    }
  end

  def response( params = {} )
    defs    = defaults.dup
    headers = params.delete :headers

    defs[:headers].merge! headers || {}

    defs.merge( params ).tap do |p|
      p[:body] = p[:body].to_json
    end
  end

  def api_server_error
    @rspec.stub_request( :any, 'example.com/api' )
      .to_return response( body:{error:'500 Server Error'}, status:500 )
  end

  def api_client_error( type = :json )
    body = '404 Not Found'

    body = { 'error' => body }.to_json if type == :json

    @rspec.stub_request( :any, 'example.com/api' )
      .to_return defaults.merge( body:body, status:404 )
  end

  def api_description
    @rspec.stub_request( :any, 'example.com/api' )
      .to_return response( body:schema, headers:{ 'Cache-Control' => 'max-age=3600, public' } )
  end

  def unknown_resource
    @rspec.stub_request( :get, 'example.com/api/my_temp_resources/1' )
      .to_return response( body:{ 'error' => '404 Not Found' }, status:404 )
  end

  def known_resource
    @rspec.stub_request( :get, 'example.com/api/my_temp_resources/1' )
      .to_return response( body:{ 'name' => 'Resource Name' } )
  end

  def schema
    {
      _embedded: {
        schema: {
          my_temp_resource: {
            description: 'Humanized resource description',
            properties: {
              name: 'string'
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

end

RSpec.configure do |c|
  c.before :all do
    @stubs = HttpStubs.new( self )
  end
end