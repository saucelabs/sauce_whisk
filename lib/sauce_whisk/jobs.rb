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
  attr_writer :updated_fields
  
  def self.tracked_attr_accessor(*methods)
    methods.each do |method|
      attr_reader method
      self.define_method("#{method}=") do |arg|
        if method != arg 
          updated_fields << method
          instance_variable_set("@#{method}", arg)
        end
      end
    end
  end

  tracked_attr_accessor :id, :owner, :browser, :browser_version, :os, :status, :error, :creation_time, :start_time, :end_time, :video_url, :log_url, :tags, :name, :public

  def initialize(parameters={})
    parameters.each do |k,v|
      self.send("#{k}=",v)
    end
  end

  def save
    Jobs.save(self)
  end

  def updated_fields
    @updated_fields ||= []
  end
end
