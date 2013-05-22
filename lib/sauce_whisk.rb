require "sauce_whisk/version"
require "sauce_whisk/jobs"
require "sauce_whisk/rest_request_builder"

module SauceWhisk

  def self.base_url
    "https://saucelabs.com/rest/v1"
  end

  def self.username
    puts ENV.inspect
    ENV["SAUCE_USERNAME"]
  end

  def self.password
    ENV["SAUCE_ACCESS_KEY"]
  end

  def self.pass_job(job_id)
    Jobs.pass_job job_id
  end
end
