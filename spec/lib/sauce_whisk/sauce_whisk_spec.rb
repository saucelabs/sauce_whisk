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
      expect( SauceWhisk::Jobs ).to receive(:pass_job).with(job_id) {true}
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
      expect( SauceWhisk.logger ).to be dummy_logger
    end

    it "defaults to STDIN" do
      SauceWhisk.logger = nil
      expect( SauceWhisk.logger ).to be STDOUT
    end
  end

  describe "##retries" do
    it "tries to read from Sauce.config" do
      SauceWhisk.instance_variable_set(:@asset_fetch_retries, nil)
      mock_config = Class.new(Hash) do
        def initialize
          self.store(:asset_fetch_retries, 3)
        end
      end

      stub_const "::Sauce::Config", mock_config
      expect( SauceWhisk.asset_fetch_retries ).to equal 3
    end
  end
end
