require "spec_helper"

describe SauceWhisk::Tunnels, :vcr => {:cassette_name => "tunnels"} do
  let(:auth) {"#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}"}
  let(:user) {ENV["SAUCE_USERNAME"]}

  describe "##all" do
    it "lists all tunnels a user has open" do
      SauceWhisk::Tunnels.all
      assert_requested :get, "https://saucelabs.com/rest/v1/#{user}/tunnels", :headers => basic_auth
    end

    it "returns nothing when no tunnels are found", :vcr => {:cassette_name => "no_tunnels", :exclusive => true} do
      tunnels = SauceWhisk::Tunnels.all
      expect( tunnels ).to eq []
    end

    context "called without the 'fetch' parameter" do
      it "returns an array of Tunnels" do
        tunnels = SauceWhisk::Tunnels.all
        expect( tunnels ).to be_an_instance_of Array
        tunnels.each {|tunnel| expect( tunnel ).to be_an_instance_of SauceWhisk::Tunnel}
      end
    end

    context "called with the fetch parameter set false" do
      it "returns an array of strings" do
        tunnels = SauceWhisk::Tunnels.all(:fetch_each => false)
        expect( tunnels ).to be_an_instance_of Array
        tunnels.each {|tunnel| expect( tunnel ).to be_an_instance_of String }
      end
    end
  end

  describe "##fetch" do
    let(:job_id) {"fcf7b980037b4a37aa5ff19808e46da7"}
    it "fetches a single instance of a tunnel" do
      SauceWhisk::Tunnels.fetch job_id
      assert_requested :get, "https://saucelabs.com/rest/v1/#{user}/tunnels/#{job_id}", :headers => basic_auth
    end

    it "returns instances of Tunnel" do
      tunnel = SauceWhisk::Tunnels.fetch job_id
      expect( tunnel ).to be_an_instance_of SauceWhisk::Tunnel
    end

    it "raises an exception with called without an id" do
      expect {SauceWhisk::Tunnels.fetch(nil)}.to raise_exception ArgumentError
    end
  end

  describe "##stop" do
    it "calls the correct API method" do
      tunnel_id = "7a4815f52407435581517ffd4d71c3a7"
      SauceWhisk::Tunnels.stop tunnel_id
      assert_requested :delete, "https://saucelabs.com/rest/v1/#{user}/tunnels/#{tunnel_id}", :headers => basic_auth
    end
  end

  describe "##open" do
    let(:params) {{:tunnel_identifier => "bees", :ssh_port => 9123, :use_caching_proxy => false, :use_kgp => true}}
    it "calls the correct API method" do
      SauceWhisk::Tunnels.open params
      assert_requested :post, "https://saucelabs.com/rest/v1/#{user}/tunnels",:body => params.to_json, :headers => basic_auth
    end

    it "returns an instance of tunnel" do
      tunnel = SauceWhisk::Tunnels.open params
      expect( tunnel ).to be_an_instance_of SauceWhisk::Tunnel

      # These aren't magic, they're taken from the tunnels fixture.  <3 VCR.
      expect( tunnel.id ).to eq "4824d6b282e04d1184daff5401a52e1e"
      expect( tunnel.ssh_port ).to eq 9123
    end

    context "When asked to wait until running", :vcr => {:cassette_name => 'tunnels_with_wait'} do
      it "calls fetch on the opened tunnel until the status is running" do
        requested_tunnel = SauceWhisk::Tunnels.open params
        t_id = requested_tunnel.id

        # There are 3 failing and 1 passing examples in the fixture
        assert_requested :get, "https://saucelabs.com/rest/v1/#{user}/tunnels/#{t_id}", :headers => basic_auth, :times => 4
      end

      it "throws an exception if the timeout is exceeded" do
        requested_tunnel = SauceWhisk::Tunnels.open params
      end
    end
  end
end
