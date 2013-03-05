require 'json'

require 'sauce_whisk/rest_request_builder'

class Jobs
  extend RestRequestBuilder

  def self.resource
    "#{SauceWhisk.username}/jobs"
  end

  def self.all
    all_jobs = JSON.parse get
    all_jobs.map {|job| Job.new(job)}
  end

  def self.change_status(job_id, status)
    put job_id, {"passed" => status}.to_json
  end

  def self.pass_job(job_id)
    change_status(job_id, true)    
  end

  def self.fail_job(job_id)
    change_status(job_id, false)
  end
end

class Job
    attr_accessor :id, :owner, :status, :error, :name, :browser, :browser_version, :os, :creation_time, :start_time, :end_time, :video_url, :log_url, :public, :tags

  def initialize(parameters={})
    parameters.each do |k,v|
      self.send("#{k}=",v)
    end
  end
end
