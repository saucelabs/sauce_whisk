require "spec_helper"

describe SauceWhisk::Accounts, :vcr => {:cassette_name => "accounts"} do
  let(:auth) {"#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}"}

  describe "#fetch" do
    it "fetches the passed in account" do
      SauceWhisk::Accounts.fetch ENV["SAUCE_USERNAME"]
      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/users/#{ENV["SAUCE_USERNAME"]}"
    end

    it "returns an Account object" do
      SauceWhisk::Accounts.fetch(ENV["SAUCE_USERNAME"]).should be_an_instance_of SauceWhisk::Account
    end

    it "includes the concurrency by default" do
      account = SauceWhisk::Accounts.fetch ENV["SAUCE_USERNAME"]
      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/#{ENV["SAUCE_USERNAME"]}/limits"
      account.total_concurrency.should eq 20
      account.mac_concurrency.should eq 5
    end

    it "should not include concurrency when conservative is set to false" do
      account = SauceWhisk::Accounts.fetch(ENV["SAUCE_USERNAME"], false)
      assert_not_requested :get, "https://#{auth}@saucelabs.com/rest/v1/#{ENV["SAUCE_USERNAME"]}/limits"
      account.total_concurrency.should be_nil
    end
  end

  describe "#concurrency_for" do
    it "fetches the concurrency for the passed in account" do
      SauceWhisk::Accounts.concurrency_for ENV["SAUCE_USERNAME"]
      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/#{ENV["SAUCE_USERNAME"]}/limits"
    end

    it "returns concurrencies with altered names" do
      expected_hash = {:mac_concurrency => 5, :total_concurrency => 20}
      SauceWhisk::Accounts.concurrency_for(ENV["SAUCE_USERNAME"]).should eq expected_hash
    end

    it "returns just mac as an integer when requested" do
      SauceWhisk::Accounts.concurrency_for(ENV["SAUCE_USERNAME"], :mac).should eq 5
    end

    it "returns just the total as an integer when requested" do
      SauceWhisk::Accounts.concurrency_for(ENV["SAUCE_USERNAME"], :total).should eq 20
    end
  end
end