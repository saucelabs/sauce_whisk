module RestRequestBuilder

  def get(resource=nil)
    RestClient::Request.execute({:method => :get, :url => fully_qualified_resource}.merge auth_details) 
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
    @fully_qualified_resource ||= "#{SauceWhisk.base_url}/#{resource}"
  end
end
