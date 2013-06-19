require "spec_helper"

describe SauceWhisk::Tunnels, :vcr => {:cassette_name => "tunnels"} do
  let(:auth) {"#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}"}

  describe "##all" do
    it "lists all tunnels a user has open" do
      SauceWhisk::Tunnels.all
      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/tunnels"
    end

    it "returns nothing when no tunnels are found", :vcr => {:cassette_name => "no_tunnels", :exclusive => true} do
      tunnels = SauceWhisk::Tunnels.all
      tunnels.should eq []
    end

    context "called without the 'fetch' parameter" do
      it "returns an array of Tunnels" do
        tunnels = SauceWhisk::Tunnels.all
        tunnels.should be_an_instance_of Array
        tunnels.each {|tunnel| tunnel.should be_an_instance_of SauceWhisk::Tunnel}
      end
    end

    context "called with the fetch parameter set false" do
      it "returns an array of strings" do
        tunnels = SauceWhisk::Tunnels.all(:fetch_each => false)
        tunnels.should be_an_instance_of Array
        tunnels.each {|tunnel| tunnel.should be_an_instance_of String }
      end
    end
  end

  describe "##fetch" do
    let(:job_id) {"fcf7b980037b4a37aa5ff19808e46da7"}
    it "fetches a single instance of a tunnel" do
      SauceWhisk::Tunnels.fetch job_id
      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/tunnels/#{job_id}"
    end

    it "returns instances of Tunnel" do
      tunnel = SauceWhisk::Tunnels.fetch job_id
      tunnel.should be_an_instance_of SauceWhisk::Tunnel
    end
  end

  describe "##stop" do
    it "calls the correct API method" do
      tunnel_id = "7a4815f52407435581517ffd4d71c3a7"
      SauceWhisk::Tunnels.stop tunnel_id
      assert_requested :delete, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/tunnels/#{tunnel_id}"
    end
  end
end