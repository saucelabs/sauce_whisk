require "rest-client"

module SauceWhisk
  module RestRequestBuilder

    def get(resource_to_fetch=nil)
      resource_url = fully_qualified_resource
      resource_url << "/#{resource_to_fetch}" if resource_to_fetch
      RestClient::Request.execute({:method => :get, :url => resource_url}.merge auth_details)
    end

    def put(resource_id, body={})
      url = "#{fully_qualified_resource}/#{resource_id}"
      length = body.length
      headers = {"Content-Length" => length}
      req_params = {
          :method => :put,
          :url => url,
          :payload => body,
          :content_type => "application/json",
          :headers => headers
      }
      RestClient::Request.execute(req_params.merge auth_details)
    end

    def delete(resource_id)
      resource_to_delete = fully_qualified_resource << "/#{resource_id}"
      RestClient::Request.execute({:method => :delete, :url => resource_to_delete}.merge auth_details)
    end

    def post(resource_parameters)
      url = fully_qualified_resource
      length = resource_parameters.length
      headers = {"Content-Length" => length}
      req_params = {
          :method => :post,
          :url => url,
          :content_type => "application/json",
          :headers => headers
      }

      req_params.merge!({:payload => resource_parameters}) if !resource_parameters.nil?

      RestClient::Request.execute(req_params.merge auth_details)

    end

    def auth_details
      {:user => SauceWhisk.username, :password => SauceWhisk.password}
    end

    def fully_qualified_resource
      return (respond_to? :resource) ? "#{SauceWhisk.base_url}/#{resource}" : SauceWhisk.base_url
    end
  end
end