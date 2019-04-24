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
    case data_center
    when :US_WEST
      "https://saucelabs.com/rest/v1"
    when :US_EAST
      "https://us-east-1.saucelabs.com/rest/v1"
    when :EU_VDC
      "https://eu-central-1.saucelabs.com/rest/v1"
    else
      raise ::ArgumentError.new "No Data Center Selected (Which should not happen?)"
    end
  end

  def self.username= username
    @username = username
  end

  def self.access_key= access_key
    @access_key = access_key
  end

  def self.username
    configured_username = self.load_first_found(:username)
    return configured_username unless configured_username.nil? || configured_username.empty?
    raise ::ArgumentError.new "Couldn't find Username in Sauce::Config, yaml file or Environment Variables"
  end

  def self.password
    configured_key = self.load_first_found(:access_key)
    return configured_key unless configured_key.nil? || configured_key.empty?
    raise ::ArgumentError.new "Couldn't find Access Key in Sauce::Config, yaml file or Environment Variables"
  end

  def self.asset_fetch_retries=(retries)
    @asset_fetch_retries = retries
  end

  def self.asset_fetch_retries
    if @asset_fetch_retries
      return @asset_fetch_retries
    end

    retries = self.load_first_found(:asset_fetch_retries)

    return retries.to_i if retries
    return 1
  end

  def self.rest_retries=(retries)
    @rest_retries = retries
  end

  def self.rest_retries
    if @rest_retries
      return @rest_retries
    end

    retries = self.load_first_found(:rest_retries)

    return retries.to_i if retries
    return 1
  end

  def self.data_center
    configured_dc = self.load_first_found(:data_center)
    
    if configured_dc.nil?
      logger.warn "[DEPRECATED] You have not selected a REST API Endpoint - using US by default. This behaviour is deprecated and will be removed in an upcoming version. Please select a data center as described here: https://github.com/saucelabs/sauce_whisk#data-center"
      configured_dc = :US_WEST
    end

    validated_dc = validate_dc configured_dc
    validated_dc
  end

  def self.data_center= dc
    @data_center = validate_dc dc
  end

  def self.validate_dc dc
    dc = :eu_vdc if dc.to_s.upcase.to_sym == :EU
    dc = :us_west if dc.to_s.upcase.to_sym == :US
    dc = :us_west if dc.to_s.upcase.to_sym == :US_VDC

    ucdc = dc.to_s.upcase.to_sym

    if ![:EU_VDC, :US_EAST, :US_WEST].include? ucdc
      raise ::ArgumentError.new("Invalid data center requested: #{ucdc}.  Value values are :EU_VDC, :US_EAST and :US_WEST.")
    end

    @data_center = ucdc
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
    value = self.instance_variable_get "@#{key}".to_sym

    unless value
      value = ::Sauce::Config.new[key] if defined? ::Sauce
    end

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