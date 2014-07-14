require "sauce_whisk/rest_request_builder"
require "sauce_whisk/version"
require "sauce_whisk/jobs"
require "sauce_whisk/assets"
require "sauce_whisk/tunnels"
require "sauce_whisk/info"
require "sauce_whisk/accounts"
require "sauce_whisk/storage"

require 'yaml'
require 'logger'


module SauceWhisk

  def self.base_url
    "https://saucelabs.com/rest/v1"
  end

  def self.username
    return self.load_first_found(:username)
  end

  def self.password
    return self.load_first_found(:access_key)
  end

  def self.asset_fetch_retries
    retries = self.load_first_found(:asset_fetch_retries)

    return retries.to_i if retries
    return 1
  end

  def self.rest_retries
    retries = self.load_first_found(:rest_retries)

    return retries.to_i if retries
    return 1
  end

  def self.pass_job(job_id)
    Jobs.pass_job job_id
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger||= default_logger
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

  def self.load_first_found(key)
    value = ::Sauce::Config.new[key] if defined? ::Sauce
    value = self.from_yml(key) unless value
    unless value
      env_key = "SAUCE_#{key.to_s.upcase}" 
      value = ENV[env_key]
    end
    
    return value
  end

  class JobNotComplete < StandardError
  end

  private

  def self.default_logger
    log = ::Logger.new(STDOUT)
    log.level = Logger::WARN
    log
  end
end 