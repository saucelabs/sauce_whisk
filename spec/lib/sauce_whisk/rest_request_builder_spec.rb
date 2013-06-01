require "spec_helper"
require "rest_client"

describe SauceWhisk::RestRequestBuilder do
  let(:dummy_client) { 
      Class.new do 
        extend SauceWhisk::RestRequestBuilder

        def self.resource
          "dummy"
        end
      end 
  }

  let (:mock_auth) {{
    :user => ENV["SAUCE_USERNAME"],
    :password => ENV["SAUCE_ACCESS_KEY"]
  }}

  describe "#auth_details" do
    it "should return the env vars" do
      dummy_client.auth_details.should eq mock_auth
    end
  end

  describe "#get" do
    before :all do
      VCR.insert_cassette 'rest_request', :record => :new_episodes
    end
    after :all do
      VCR.eject_cassette
    end

    it "should call the base URL with the resource name" do
      expected_url = "#{SauceWhisk.base_url}/#{dummy_client.resource}"
      expected_params = {:method => :get, :url => expected_url}.merge mock_auth
      RestClient::Request.should_receive(:execute).with(expected_params)
      dummy_client.get
    end
  end

  describe "#put", :vcr => {:cassette_name => 'jobs'} do
    it "calls the base URL with the put method" do
      expected_url = "#{SauceWhisk.base_url}/#{dummy_client.resource}/something"
      expected_params = {:method => :put, :url => expected_url, :payload => "another_thing", :content_type => "application/json"}.merge mock_auth
      RestClient::Request.should_receive(:execute).with(expected_params)
      dummy_client.put "something", "another_thing"
    end
  end
end
