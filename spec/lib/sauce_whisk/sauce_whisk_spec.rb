require "spec_helper"

describe SauceWhisk do
  describe "##base_url" do
    subject {SauceWhisk.base_url}
    it {should eq "https://saucelabs.com/rest/v1"}

  end

  describe "##username" do
    subject {SauceWhisk.username}
    it {should eq ENV["SAUCE_USERNAME"]}
  end

  describe "##password" do
    subject {SauceWhisk.password}
    it {should eq ENV["SAUCE_PASSWORD"]}
  end
end
