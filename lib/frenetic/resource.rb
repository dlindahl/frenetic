class Frenetic
  class Resource

    def api
      self.class.api
    end

    def self.api_client( client = nil )
      if client
        @api_client = client
      elsif block_given?
        @api_client = Proc.new
      elsif @api_client.is_a? Proc
        @api_client.call
      else
        @api_client
      end
    end

  end
end