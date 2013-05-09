require 'faraday_middleware/response_middleware'

class Frenetic
  module Middleware
    class HalJson < FaradayMiddleware::ParseJson

      def process_response(env)
        super

        if (500...599).include? env[:status]
          raise ServerError, env[:body]['error']
        elsif (400...499).include? env[:status]
          raise ClientError, env[:body]['error']
        end
      rescue Faraday::Error::ParsingError => err
        raise ParsingError, err.message
      end

    end
  end
end

Faraday.register_middleware :response, hal_json:lambda { Frenetic::Middleware::HalJson }