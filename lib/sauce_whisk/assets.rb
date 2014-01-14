module SauceWhisk
  class Assets
    extend RestRequestBuilder

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
        retry
      else
        raise e
      end
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