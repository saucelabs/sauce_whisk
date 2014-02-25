module SauceWhisk
  class AccountError < StandardError; end
  class SubAccountCreationError < AccountError; end
  class InvalidAccountError < StandardError; end

  class Accounts
    extend SauceWhisk::RestRequestBuilder

    def self.fetch(user_id = ENV["SAUCE_USERNAME"], get_concurrency = true)
      user_parameters = JSON.parse (get "users/#{user_id}"), :symbolize_names => true
      concurrencies = get_concurrency ? concurrency_for(user_id) : {}

      account_parameters = user_parameters.merge concurrencies
      return Account.new(account_parameters)
    rescue RestClient::ResourceNotFound
      raise InvalidAccountError, "Account #{user_id} does not exist"
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

    #TODO what happens if not a valid parent?
    def self.create_subaccount(parent, name, username, email, password)
      payload = {
        :username => username,
        :password => password,
        :name => name,
        :email => email
      }
      begin
        response = post :resource => "users/#{parent.username}", :payload => payload
      rescue RestClient::BadRequest => e
        decoded_body = JSON.parse e.http_body, :symbolize_names => true
        raise SubAccountCreationError, decoded_body[:errors]
      rescue RestClient::ResourceNotFound => e
        raise InvalidAccountError, "Parent account #{parent.username} does not exist"
      end

      new_subaccount = SubAccount.new parent, JSON.parse(response)
    end
  end

  class Account
    attr_reader :access_key, :username, :total_concurrency, :mac_concurrency
    attr_reader :minutes, :mac_minutes, :manual_minutes, :mac_manual_minutes
    def initialize(options)
      @access_key = options[:access_key]
      @username = options[:id]
      @minutes = options[:minutes]
      @mac_minutes = options[:mac_minutes]
      @manual_minutes = options[:manual_minutes]
      @mac_manual_minutes = options[:mac_manual_minutes]
      @total_concurrency = options[:total_concurrency]
      @mac_concurrency = options[:mac_concurrency]
    end

    def add_subaccount(name, username, email, password)
      SauceWhisk::Accounts.create_subaccount(self, name, username, email, password)
    end
  end

  class SubAccount < Account
    attr_reader :parent

    def initialize(parent, options)
      @parent = parent
      super(options)
    end
  end
end