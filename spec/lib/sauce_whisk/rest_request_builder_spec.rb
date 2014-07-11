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
        expect( dummy_client.fully_qualified_resource ).to eq "#{SauceWhisk.base_url}/#{dummy_client.resource}"
      end
    end

    context "without a resource defined" do
      it "should return the base url" do
        expect( dummy_client_without_resource.fully_qualified_resource ).to eq SauceWhisk.base_url
      end
    end
  end

  describe "#auth_details" do
    it "should return the env vars" do
      expect( dummy_client.auth_details ).to eq mock_auth
    end
  end

  describe "#make_request" do
    before :all do
      VCR.insert_cassette 'rest_request_retry', :record => :new_episodes
    end

    after :all do
      VCR.eject_cassette
    end

    it "should retry 404'd methods n times" do
      expected_url = "#{SauceWhisk.base_url}/#{dummy_client.resource}"
      expected_params = {:method => :get, :url => expected_url}.merge mock_auth
      times = 0
      expect( RestClient::Request ).to receive(:execute) do |arg|
        expect(arg).to eq expected_params
          raise RestClient::ResourceNotFound.new if(times >= SauceWhisk.rest_retries)
        times += 1
      end    
      dummy_client.get
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
      expect( RestClient::Request ).to receive(:execute).with(expected_params)
      dummy_client.get
    end
  end

  describe "#delete", :vcr => {:cassette_name => 'jobs'} do
    let(:expected_url) {"#{SauceWhisk.base_url}/#{dummy_client.resource}/identifier"}

    it "calls the base URL with the delete method" do
      expected_params = {:method => :delete, :url => expected_url}.merge mock_auth
      expect( RestClient::Request ).to receive(:execute).with(expected_params)
      dummy_client.delete "identifier"
    end
  end

begin
  describe "#post", :vcr => {:cassette_name => 'tunnels'} do
    let(:expected_payload) {{:tunnel_identifier => "KarlMarx"}}
    it "calls the base URL" do
      expected_url = "#{SauceWhisk.base_url}/#{dummy_client.resource}"
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:url => expected_url}))

      dummy_client.post(:payload => expected_payload)
    end

    it "uses the correct method" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:method => :post}))
      dummy_client.post(:payload => expected_payload)
    end

    it "includes the correct payload, in JSON" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:payload => expected_payload.to_json}))
      dummy_client.post(:payload => expected_payload)
    end

    it "includes the correct content_type" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:content_type => "application/json"}))
      dummy_client.post(:payload => expected_payload)
    end

    it "includes the correct length" do
      expected_length = expected_payload.to_json.length
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:headers => {"Content-Length" => expected_length}}))
      dummy_client.post(:payload => expected_payload)
    end

    it "includes the authentication parameters" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including(mock_auth))
      dummy_client.post(:payload => expected_payload)
    end

    it "allows for base resource additions" do
      expected_url = "#{SauceWhisk.base_url}/#{dummy_client.resource}/dummy_res"
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:payload => expected_payload.to_json, :url => expected_url}))

      dummy_client.post(:payload => expected_payload, :resource =>"dummy_res")
    end
  end
end

  describe "#put", :vcr => {:cassette_name => 'jobs'} do
    let(:expected_url) {"#{SauceWhisk.base_url}/#{dummy_client.resource}/something"}
    it "calls the base URL with the put method" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:url => expected_url}))
      dummy_client.put "something", "another_thing"
    end

    it "includes the right content_type" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:content_type => "application/json"}))
      dummy_client.put "something", "another_thing"
    end

    it "includes the right method" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:method => :put}))
      dummy_client.put "something", "another_thing"
    end

    it "includes the content length" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including(:headers => {"Content-Length" => 13}))
      dummy_client.put "something", "another_thing"
    end

    it "includes authentication details" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including(mock_auth))
      dummy_client.put "something", "another_thing"
    end

    it "sends the payload" do
      expect( RestClient::Request ).to receive(:execute).with(hash_including({:payload => "another_thing"}))
      dummy_client.put "something", "another_thing"
    end
  end
end
