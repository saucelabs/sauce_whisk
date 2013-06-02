require 'json'

require 'sauce_whisk/rest_request_builder'

module SauceWhisk
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
    rescue e
      SauceWhisk.logger "Unable to change_status for #{job_id} to #{status}\nReason: #{e.to_s}"
    end

    def self.pass_job(job_id)
      change_status(job_id, true)
    end

    def self.fail_job(job_id)
      change_status(job_id, false)
    end

    def self.save(job)
      fields_to_save = job.updated_fields.each_with_object(Hash.new) do |field, hsh|
        hsh[field] = job.send(field.to_s)
      end
      put job.id, fields_to_save.to_json
    end

    def self.fetch(job_id)
      job_hash = JSON.parse(get job_id)
      assets = JSON.parse get "#{job_id}/assets"
      screenshots = assets["screenshots"]

      job_hash.merge!({"screenshot_urls" => screenshots})
      Job.new(job_hash)
    end

    def self.fetch_asset(job_id, asset)
      asset = get "#{job_id}/assets/#{asset}"
    end
  end

  class Job
    attr_writer :updated_fields

    def self.tracked_attr_accessor(*methods)
      methods.each do |method|
        attr_reader method
        self.send(:define_method, "#{method}=") do |arg|
          if method != arg
            updated_fields << method
            instance_variable_set("@#{method}", arg)
          end
        end
      end
    end

    attr_reader :id, :owner, :browser, :browser_version, :os, :log_url
    attr_reader :error, :creation_time, :start_time, :end_time, :video_url
    attr_reader :screenshot_urls

    tracked_attr_accessor :custom_data, :tags, :name, :visibility, :build, :passed

    def initialize(parameters={})
      passed = parameters.delete "status"
      cd = parameters.delete "custom-data"
      visibility = parameters.delete "public"

      self.passed = passed
      self.custom_data = cd
      self.visibility = visibility

      parameters.each do |k,v|
        self.instance_variable_set("@#{k}".to_sym, v)
      end

      @updated_fields = []
    end

    def save
      Jobs.save(self)
    end

    def updated_fields
      @updated_fields ||= []
    end

    def screenshots
      unless @screenshots
       @screenshots = screenshot_urls.map do |screenshot|
          Assets.fetch id, screenshot
        end
      end

      @screenshots
    end

    def video
      unless @video
        @video = Assets.fetch id, "video.flv", :video
      end

      @video
    end
  end
end