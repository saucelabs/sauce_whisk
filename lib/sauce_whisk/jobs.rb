require 'json'

require 'sauce_whisk/rest_request_builder'

class Jobs
  extend RestRequestBuilder

  def self.resource
    "#{ENV["SAUCE_USERNAME"]}/jobs"
  end

  def self.all
    all_jobs = JSON.parse get
    all_jobs.map {|job| Job.new(job)}
  end

  def self.change_status(job_id, status)
    put job_id, {"passed" => status}.to_json
  end

  def self.pass_job(job_id)
    
  end
end

class Job
  def initialize(parameters={})
  end
end
