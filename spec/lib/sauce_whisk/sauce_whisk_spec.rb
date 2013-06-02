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
      SauceWhisk::Jobs.should_receive(:pass_job).with(job_id) {true}
      SauceWhisk.pass_job job_id
    end
  end

  describe "##logger" do
    it "accepts a logger object" do
      dummy_logger = Object.new do
        def puts(input)
        end
      end
      SauceWhisk.logger = dummy_logger
      SauceWhisk.logger.should be dummy_logger
    end

    it "defaults to STDIN" do
      SauceWhisk.logger = nil
      SauceWhisk.logger.should be STDOUT
    end
  end
end
