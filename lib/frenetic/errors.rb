class Frenetic
  # Generic Frenetic exception class.
  Error = Class.new(StandardError)

  # Raised when there is a configuration error
  ConfigError = Class.new(Error)

  # Raised when there is a Hypermedia error
  HypermediaError = Class.new(Error)

  # Raised when there is a Link Template error
  LinkTemplateError = Class.new(Error)

  # Raised when a Resource does not have a mock class defined.
  #
  # For example:
  #
  # class Widget < Frenetic::Resource
  # end
  #
  # class MockWidget < Widget
  #   include Frenetic::ResourceMockery
  # end
  #
  # Would correctly create the necessary Mock Resource
  class UndefinedResourceMock < Error
    attr_reader :namespace, :resource
    def initialize(namespace, resource)
      @namespace = namespace
      @resource = resource
    end

    def message
      "Mock resource not defined for `#{namespace}`." \
        " Create a new class that inherits from `#{resource}` and mixin" \
        " `Frenetic::ResourceMockery` to define a mock."
    end
  end

  # Parent class for all specific exceptions which are raised as a result of a
  # network response.
  class ResponseError < Error
    attr_reader :env, :error, :method, :status, :url
    def initialize(env)
      env ||= {}
      body = env.fetch(:body, {})
      @env = env
      @error = body['error']
      @method = env[:method]
      @status = env[:status]
      @url = env[:url]
      super(message)
    end

    def message
      @error
    end
  end

  # Raised when a network response returns a 400-level error
  ClientError = Class.new(ResponseError)

  # Raised when a network response returns a 500-level error
  ServerError = Class.new(ResponseError)

  # Parent class for all specific exceptions which are raised as a result of a
  # parsing the network request response body.
  class ParsingError < ResponseError
    def message
      "#{status} Error"
    end
  end

  # Raised when there is a problem parsing the response body of a 400-level error
  ClientParsingError = Class.new(ParsingError)

  # Raised when there is a problem parsing the response body of a 400-level error
  ServerParsingError = Class.new(ParsingError)

  # Raised when there is a problem parsing the response body of an otherwise
  # successful network request. Provides access to the original exception also.
  class UnknownParsingError < ParsingError
    attr_reader :original_exception
    def initialize(env, err)
      @original_exception = err
      super(env)
    end

    def message
      @original_exception.message
    end
  end
end