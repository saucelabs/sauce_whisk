require "rest-client"

RestClient.proxy = ENV["http_proxy"] if ENV["http_proxy"]
RestClient.proxy = ENV["HTTP_PROXY"] if ENV["HTTP_PROXY"]

module SauceWhisk
  module RestRequestBuilder

    def get(resource_to_fetch=nil)
      resource_url = fully_qualified_resource
      resource_url << "/#{resource_to_fetch}" if resource_to_fetch
      make_request({:method => :get, :url => resource_url}.merge auth_details)
    end

    def put(resource_id, body={})
      url = "#{fully_qualified_resource}/#{resource_id}"
      length = body.length
      headers = {"Content-Length" => length}
      req_params = {
          :method => :put,
          :url => url,
          :payload => body,
          :content_type => :json,
          :headers => headers
      }
      make_request(req_params.merge auth_details)
    end

    def delete(resource_id)
      resource_to_delete = fully_qualified_resource << "/#{resource_id}"
      make_request({:method => :delete, :url => resource_to_delete}.merge auth_details)
    end

    def post(opts)
      payload = (opts[:payload].to_json)
      resource_id = opts[:resource] || nil

      url = fully_qualified_resource
      url << "/#{resource_id}" if resource_id

      length = payload.length
      headers = {"Content-Length" => length}
      req_params = {
          :method => :post,
          :url => url,
          :content_type => "application/json",
          :headers => headers
      }

      req_params.merge!({:payload => payload}) unless payload.nil?

      make_request(req_params.merge auth_details)
    end

    def make_request(req_params)
      SauceWhisk.logger.debug "Performing Request: \n#{req_params}"
      request_from_rest_client req_params
    end

    def request_from_rest_client(req_params)
      tries ||= SauceWhisk.rest_retries
      RestClient::Request.execute(req_params)
    rescue RestClient::ResourceNotFound => e
      if (tries -= 1) > 0
        retry
      else
        raise e
      end    
    end

    def auth_details
      {:user => SauceWhisk.username, :password => SauceWhisk.password}
    end

    def fully_qualified_resource
      return (respond_to? :resource) ? "#{SauceWhisk.base_url}/#{resource}" : SauceWhisk.base_url
    end
  end
end