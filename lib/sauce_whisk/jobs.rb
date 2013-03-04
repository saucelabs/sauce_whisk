require 'json'

require 'sauce_whisk/rest_request_builder'

class Jobs
  extend RestRequestBuilder

  def self.resource
    "#{ENV["SAUCE_USERNAME"]}/jobs"
  end

  def self.all
    all_jobs = JSON.parse get  
  end

  def change_status
  end

end

class Job
end
