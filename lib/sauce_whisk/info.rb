require "json"
require 'sauce_whisk/rest_request_builder'

module SauceWhisk
  class Sauce
    extend RestRequestBuilder

    def self.auth_details
      {}
    end

    def self.resource
      "info"
    end

    def self.service_status
      JSON.parse((get "status"), :symbolize_names => true)
    rescue

    end

    def self.platforms (force = false)
      unless force
        @platforms ||= JSON.parse(get "browsers/webdriver")
      else
        @platforms = JSON.parse(get "browsers/webdriver")
      end
    end

    def self.total_job_count
      Integer(get "counter")
    end

    def self.operational?
      service_status[:service_operational]
    end
  end
end