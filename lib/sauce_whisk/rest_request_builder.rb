module RestRequestBuilder

  def get
    RestClient::Request.execute({:method => :get, :url => fully_qualified_resource}.merge auth_details) 
  end

  def auth_details
    {:user => ENV["SAUCE_USERNAME"], :password => ENV["SAUCE_ACCESS_KEY"]}
  end

  def fully_qualified_resource
    @fully_qualified_resource ||= "#{SauceWhisk.base_url}/#{resource}"
  end
end
