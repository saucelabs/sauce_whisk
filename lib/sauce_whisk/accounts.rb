module SauceWhisk
  class Accounts
    extend SauceWhisk::RestRequestBuilder

    def self.fetch(user_id = ENV["SAUCE_USERNAME"], get_concurrency = true)
      user_parameters = JSON.parse (get "users/#{user_id}"), :symbolize_names => true
      concurrencies = get_concurrency ? concurrency_for(user_id) : {}

      account_parameters = user_parameters.merge concurrencies
      return Account.new(account_parameters)
    end

    def self.concurrency_for(job_id = ENV["SAUCE_USERNAME"], type = :both)
      concurrencies = JSON.parse (get "#{job_id}/limits"), :symbolize_names => true
      case type
        when :mac
          return concurrencies[:mac_concurrency]
        when :total
          return concurrencies[:concurrency]
        else
          return {:mac_concurrency => concurrencies[:mac_concurrency],
                  :total_concurrency => concurrencies[:concurrency]
          }
      end
    end

  end
  class Account
    attr_reader :access_key, :username, :minutes, :total_concurrency, :mac_concurrency
    def initialize(options)
      @access_key = options[:access_key]
      @username = options[:id]
      @minutes = options[:minutes]
      @total_concurrency = options[:total_concurrency]
      @mac_concurrency = options[:mac_concurrency]
    end
  end
end