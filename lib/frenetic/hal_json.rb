require 'json'
require 'recursive_open_struct'
require 'frenetic/hal_json/response_wrapper'

class Frenetic

  class HalJson < Faraday::Middleware
    def call( environment )
      @app.call(environment).on_complete { |env| on_complete(env) }
    end

    def on_complete( env )
      if success? env
        env[:body] = ResponseWrapper.new( JSON.parse(env[:body]) )
      end
    end

    def success?( env )
      (200..201) === env[:status]
    end
  end

end