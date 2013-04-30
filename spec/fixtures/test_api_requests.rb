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
      schema: {
        my_resource: {
          name: 'string'
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