require "sauce_whisk/rest_request_builder"
require "sauce_whisk/version"
require "sauce_whisk/jobs"
require "sauce_whisk/assets"
require "sauce_whisk/tunnels"
require "sauce_whisk/info"
require "sauce_whisk/accounts"

require 'yaml'


module SauceWhisk

  def self.base_url
    "https://saucelabs.com/rest/v1"
  end

  def self.username
    if defined? ::Sauce
      return ::Sauce::Config.new[:username]
    else
      return self.from_yml(:username) || ENV["SAUCE_USERNAME"]
    end
  end

  def self.password
    if defined? ::Sauce
      return ::Sauce::Config.new[:access_key]
    else
      return self.from_yml(:access_key) || ENV["SAUCE_ACCESS_KEY"]
    end
  end

  def self.asset_fetch_retries
    if not @asset_fetch_retries
      if defined? ::Sauce
        @asset_fetch_retries = ::Sauce::Config.new[:asset_fetch_retries]
      else
        @asset_fetch_retries = ENV["SAUCE_ASSET_FETCH_RETRIES"]
      end
    end

    return @asset_fetch_retries.to_i if @asset_fetch_retries
    return 1
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

  def self.public_link(job_id)
    key        = "#{self.username}:#{self.password}"
    auth_token = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('md5'), key, job_id)

    "https://saucelabs.com/jobs/#{job_id}?auth=#{auth_token}"
  end

  def self.from_yml(key)
    @hash_from_yaml ||= self.load_options_from_yaml
    return @hash_from_yaml[key]
  end

  def self.load_options_from_yaml
    paths = [
      "ondemand.yml",
      File.join("config", "ondemand.yml"),
      File.expand_path("../../ondemand.yml", __FILE__),
      File.join(File.expand_path("~"), ".sauce", "ondemand.yml")
    ]

    paths.each do |path|
      if File.exists? path
        conf = YAML.load_file(path)
        return conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      end
    end

    return {}
  end
end
