module SauceWhisk
  class Assets
    extend RestRequestBuilder
    class << self
      alias_method :rest_delete, :delete
    end

    def self.resource
      "#{SauceWhisk.username}/jobs"
    end

    def self.fetch(job_id, asset, type=nil)
      retries ||= SauceWhisk.asset_fetch_retries
      attempts ||= 1

      data = get "#{job_id}/assets/#{asset}"
      Asset.new({:name => asset, :data => data, :job_id => job_id, :type => type})
    rescue RestClient::ResourceNotFound => e
      if attempts <= retries
        attempts += 1
        sleep(5)
      retry
      else
        raise e
      end
    end

    def self.delete(job_id)
      retries ||= SauceWhisk.asset_fetch_retries
      attempts ||= 1

      data = rest_delete "#{job_id}/assets/"
      Asset.new({:data => data,:job_id => job_id})
    rescue RestClient::ResourceNotFound => e
      if attempts <= retries
        attempts += 1
        sleep(5)
      retry
      else
        raise e
      end
    
    # Return nil as all of the assets we're already deleted.
    rescue RestClient::BadRequest => e
      nil
      end
  end

  class Asset

    attr_reader :asset_type, :name, :data, :job
    def initialize(parameters={})
      @asset_type = parameters[:type] || :screenshot
      @name = parameters[:name]
      @data = parameters[:data]
      @job = parameters[:job_id]
    end

  end
end