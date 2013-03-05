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
    it {should eq ENV["SAUCE_ACCESS_KEY"]}
  end

  describe "##pass_job" do
    it "should call #pass on the jobs object" do
      job_id = "0418999"
      Jobs.should_receive(:pass_job).with(job_id) {true}
      SauceWhisk.pass_job job_id
    end
  end
end
