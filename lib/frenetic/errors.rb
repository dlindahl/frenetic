require 'active_support/inflector'
require 'active_support/core_ext/array/conversions'

class Frenetic
  # Generic Frenetic exception class.
  Error = Class.new(StandardError)

  # Raised when there is a configuration error
  class ConfigError < Error
    def initialize(model)
      @model = model
      super(message)
    end

    def message
      if @model.is_a? String
        @model
      else
        errs = @model.errors.collect do |key, msg|
          "#{key.to_s.titleize} #{msg}"
        end
        "Invalid Configuration: #{errs.to_sentence}"
      end
    end
  end

  class MissingDependency < ConfigError
    def initialize(lib, context, err)
      @lib, @context, @err = lib, context, err
      super(message)
    end

    def message
      "Could not load required `#{@lib}` dependency for " \
        "#{@context} (#{@err.class}: #{@err.message})"
    end
  end

  # Raised when there is a Hypermedia error
  HypermediaError = Class.new(Error)

  # Raised when there is no _link entry for the desired resource
  class MissingRelevantLink < HypermediaError
    def initialize(tmpl_vars, link_set)
      @tmpl_vars = tmpl_vars
      @link_set = link_set
    end

    def message
      "Could not find a relevant link for the data provided.\n" \
      "Are any of the links missing the templated:true property?\n" \
      "  Template Data: #{@tmpl_vars}\n" \
      "  Link Set: #{@link_set.collect(&:as_json)}"
    end
  end

  # Raised when a Resource's GET Url is not included in the _links hash
  class MissingResourceUrl < HypermediaError
    def initialize(resource)
      @resource = resource
      super(message)
    end

    def message
      %("No Hypermedia GET Url found for the resource "#{@resource}")
    end
  end

  # Raised when there is no schema defined by the Api root for the given resource
  class MissingSchemaDefinition < HypermediaError
    def initialize(namespace)
      @namespace = namespace
      super(message)
    end

    def message
      %(Could not find schema definition for the resource "#{@namespace}")
    end
  end

  # Raised when an expanded URL template is passed the wrong number of arguments
  class UnfulfilledLinkTemplate < HypermediaError
    def initialize(template, data)
      @template = template
      @data = data
    end

    def message
      "The data provided could not satisfy the template requirements.\n" \
      "  Template: #{@template.pattern}\n" \
      "  Data: #{@data}"
    end
  end

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
        ' `Frenetic::ResourceMockery` to define a mock.'
    end
  end

  # Parent class for all specific exceptions which are raised as a result of a
  # network response.
  class ResponseError < Error
    attr_reader :env, :error, :method, :status, :url
    def initialize(env)
      env ||= {}
      if env.respond_to?(:fetch)
        body = env.fetch(:body, {})
        @env = env
        @error = body['error']
        @method = env[:method]
        @status = env[:status]
        @url = env[:url]
      end
      super(message)
    end

    def message
      @error
    end
  end

  # Raised when a network response returns a 400-level error
  ClientError = Class.new(ResponseError)

  # Raise when a network reponse returns a 404 Not Found error
  class ResourceNotFound < ClientError
    def initialize(resource, params)
      @resource = resource.to_s.demodulize
      @params = params
      @status = 404
      super(message)
    end

    def message
      if @params.blank?
        "Couldn't find #{@resource} without an ID"
      else
        "Couldn't find #{@resource} with #{stringified_params}"
      end
    end

  private

    def stringified_params
      pairs = @params.each_with_object([]) do |*tuple, agg|
        agg.concat(tuple)
      end
      assignments = pairs.map do |pair|
        pair.join('=')
      end
      assignments.join(', ')
    end
  end

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
