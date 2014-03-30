require 'rubygems'
require 'restclient'
require 'json'

module SauceWhisk
  class Storage
    attr_reader :username, :key, :url, :debug

    def initialize opts={}
      @username = opts.fetch :username, ENV['SAUCE_USERNAME']
      @key      = opts.fetch :key, ENV['SAUCE_ACCESS_KEY']
      @url      = "https://#{@username}:#{@key}@saucelabs.com/rest/v1/storage/#{@username}"
      @debug    = opts.fetch :debug, false
    end

    def upload file_path
      file_name = File.basename file_path
      file      = File.new file_path
      local_md5 = Digest::MD5.hexdigest File.read file_path

      self.files.each do |file|
        if file['md5'] == local_md5
          puts 'File already uploaded' if @debug
          return true
        end
      end

      url        = "#{@url}/#{file_name}?overwrite=true"
      remote_md5 = JSON.parse(RestClient.post url, file, content_type: 'application/octet-stream')['md5']
      if @debug
        puts "Uploaded #{file_path}"
        puts " local_md5: #{local_md5}"
        puts "remote_md5: #{remote_md5}"
      end
      local_md5 == remote_md5
    end

    def files
      JSON.parse(RestClient.get @url)['files']
    end
  end
end