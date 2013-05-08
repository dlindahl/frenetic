require 'json'

class HttpStubs

  def initialize( rspec )
    @rspec = rspec
  end

  def api_server_error
    @rspec.stub_request( :any, 'example.com/api' )
      .to_return body:{error:'500 Server Error'}, status:500
  end

  def api_client_error( type = :json )
    body = '404 Not Found'

    body = { 'error' => body } if type == :json

    @rspec.stub_request( :any, 'example.com/api' )
      .to_return body:body, status:404
  end

  def api_description
    @rspec.stub_request( :any, 'example.com/api' )
      .to_return body:schema.to_json, status:200
  end

  def schema
    {
      _embedded: {
        schema: {
          my_temp_resource: {
            name: 'string'
          }
        }
      },
      _links: {
        schema: {
          href: '/api/schema'
        },
        my_resources: {
          href: '/api/my_resources'
        },
        my_resource: {
          href: '/api/my_resource/{id}',
          templated: true
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