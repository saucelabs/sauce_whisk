require "spec_helper"

describe "SauceWhisk::Info", :vcr => {:cassette_name => "info"}  do
  describe "#service_status"do
    it "calls the correct URI" do
      SauceWhisk::Sauce.service_status
      assert_requested :get, "https://saucelabs.com/rest/v1/info/status"
    end
  end

  describe "#test_count" do
    it "calls the correct URI" do
      SauceWhisk::Sauce.test_count
      assert_requested :get, "https://saucelabs.com/rest/v1/info/counter"
    end

    it "returns an integer" do
      SauceWhisk::Sauce.test_count.should be_a_kind_of Integer
    end
  end

  describe "#platforms" do
    it "calls the correct URI" do
      SauceWhisk::Sauce.platforms
      assert_requested :get, "https://saucelabs.com/rest/v1/info/browsers/webdriver"
    end

    it "only calls the api once" do
      SauceWhisk::Sauce.instance_variable_set(:@platforms, nil)
      SauceWhisk::Sauce.platforms
      SauceWhisk::Sauce.platforms
      assert_requested :get, "https://saucelabs.com/rest/v1/info/browsers/webdriver"
    end

    it "returns an array" do
      platforms = SauceWhisk::Sauce.platforms
      platforms.should be_a_kind_of Array
    end

    context "when called with true" do
      it "calls the API each time" do
        SauceWhisk::Sauce.instance_variable_set(:@platforms, nil)
        SauceWhisk::Sauce.platforms
        SauceWhisk::Sauce.platforms(true)

        assert_requested :get, "https://saucelabs.com/rest/v1/info/browsers/webdriver", :times => 2
      end
    end
  end
end