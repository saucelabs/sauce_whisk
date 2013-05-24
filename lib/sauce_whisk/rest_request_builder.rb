module RestRequestBuilder

  def get(resource_to_fetch=nil)
    resource_url = fully_qualified_resource
    resource_url << "/#{resource_to_fetch}" if resource_to_fetch
    RestClient::Request.execute({:method => :get, :url => resource_url}.merge auth_details)
  end

  def put(resource_id, body)
    url = "#{fully_qualified_resource}/#{resource_id}"
    length = body.length
    headers = {"Content-Length" => length}
    req_params = {
        :method => :put, 
        :url => url, 
        :payload => body,
        :content_type => "application/json"
    }
    RestClient::Request.execute(req_params.merge auth_details)
  end

  def auth_details
    {:user => SauceWhisk.username, :password => SauceWhisk.password}
  end

  def fully_qualified_resource
    "#{SauceWhisk.base_url}/#{resource}"
  end
end
