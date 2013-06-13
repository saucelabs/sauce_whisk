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

  let(:dummy_client_without_resource) {
    Class.new do
      extend SauceWhisk::RestRequestBuilder
    end
  }

  let (:mock_auth) {{
    :user => ENV["SAUCE_USERNAME"],
    :password => ENV["SAUCE_ACCESS_KEY"]
  }}

  describe "#fully_qualified_resource" do
    context "with a resource defined" do
      it "should end with the resource" do
        dummy_client.fully_qualified_resource.should eq "#{SauceWhisk.base_url}/#{dummy_client.resource}"
      end
    end

    context "without a resource defined" do
      it "should return the base url" do
        dummy_client_without_resource.fully_qualified_resource.should eq SauceWhisk.base_url
      end
    end
  end

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

  describe "#delete", :vcr => {:cassette_name => 'jobs'} do
    let(:expected_url) {"#{SauceWhisk.base_url}/#{dummy_client.resource}/identifier"}

    it "calls the base URL with the delete method" do
      expected_params = {:method => :delete, :url => expected_url}.merge mock_auth
      RestClient::Request.should_receive(:execute).with(expected_params)
      dummy_client.delete "identifier"
    end
  end

  describe "#put", :vcr => {:cassette_name => 'jobs'} do
    let(:expected_url) {"#{SauceWhisk.base_url}/#{dummy_client.resource}/something"}
    it "calls the base URL with the put method" do
      RestClient::Request.should_receive(:execute).with(hash_including({:url => expected_url}))
      dummy_client.put "something", "another_thing"
    end

    it "includes the right content_type" do
      RestClient::Request.should_receive(:execute).with(hash_including({:content_type => "application/json"}))
      dummy_client.put "something", "another_thing"
    end

    it "includes the right method" do
      RestClient::Request.should_receive(:execute).with(hash_including({:method => :put}))
      dummy_client.put "something", "another_thing"
    end

    it "includes the content length" do
      RestClient::Request.should_receive(:execute).with(hash_including(:headers => {"Content-Length" => 13}))
      dummy_client.put "something", "another_thing"
    end

    it "includes authentication details" do
      RestClient::Request.should_receive(:execute).with(hash_including(mock_auth))
      dummy_client.put "something", "another_thing"
    end

    it "sends the payload" do
      RestClient::Request.should_receive(:execute).with(hash_including({:payload => "another_thing"}))
      dummy_client.put "something", "another_thing"
    end
  end
end
