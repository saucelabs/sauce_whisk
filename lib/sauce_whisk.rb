require "sauce_whisk/version"
require "sauce_whisk/jobs"
require "sauce_whisk/assets"
require "sauce_whisk/tunnels"
require "sauce_whisk/rest_request_builder"

module SauceWhisk

  def self.base_url
    "https://saucelabs.com/rest/v1"
  end

  def self.username
    if defined? Sauce
      return Sauce.get_config.username
    else
      return ENV["SAUCE_USERNAME"]
    end
  end

  def self.password
    if defined? Sauce
      return Sauce.get_config.password
    else
      return ENV["SAUCE_ACCESS_KEY"]
    end
  end

  def self.pass_job(job_id)
    Jobs.pass_job job_id
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger||= STDOUT
  end
end
