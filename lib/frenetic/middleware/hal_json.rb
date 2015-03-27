require 'faraday_middleware/response_middleware'

class Frenetic
  module Middleware
    class HalJson < FaradayMiddleware::ParseJson
      def process_response(env)
        super

        case env[:status]
        when 500...599 then fail ServerError.new(env)
        when 400...499 then fail ClientError.new(env)
        end
      rescue Faraday::Error::ParsingError => err
        case env[:status]
        when 500...599 then raise ServerParsingError.new(env)
        when 400...499 then raise ClientParsingError.new(env)
        else raise UnknownParsingError.new(env, err)
        end
      end
    end
  end
end

Faraday::Response.register_middleware \
  hal_json: -> { Frenetic::Middleware::HalJson }
