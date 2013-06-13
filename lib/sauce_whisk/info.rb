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
      get "status"
    rescue

    end

    def self.platforms (force = false)
      unless force
        @platforms ||= JSON.parse(get "browsers/webdriver")
      else
        @platforms = JSON.parse(get "browsers/webdriver")
      end
    end

    def self.test_count
      Integer(get "counter")
    end
  end
end