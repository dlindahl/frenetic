class Frenetic
  module Persistence
    def save
      persist_resource
    end

    def save!
      save || fail(ResourceInvalid.new(self))
    end

    def errors=( errs )
      @_errors = errs
    end

    def errors
      @_errors
    end

    def valid?
      @_errors ? @_errors.empty? : true
    end

  private

    def persist_resource
      response = api.post(member_url(attributes), note:attributes)
      initialize_with(response.body) if response.success?
    rescue ClientError => ex
      raise if ex.status != 422
      self.errors = ex.body.fetch('errors', base: ex.error )
      return false
    else
      return true
    end
  end
end
