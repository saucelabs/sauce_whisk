require "spec_helper"

describe SauceWhisk do
  describe "##base_url" do
    subject {SauceWhisk.base_url}
    it {should eq "https://saucelabs.com/rest/v1"}

  end

  describe "##username" do
    subject {SauceWhisk.username}
    it {should eq ENV["SAUCE_USERNAME"]}

    describe "when empty" do
      subject {lambda {SauceWhisk.username}}

      around do |spec|
        @un = ENV["SAUCE_USERNAME"]
        ENV.delete "SAUCE_USERNAME"
        
        spec.run

        ENV["SAUCE_USERNAME"] = @un
      end

      it {is_expected.to raise_exception ArgumentError}
    end  
  end

  describe "##password" do
    subject {SauceWhisk.password}
    it {should eq ENV["SAUCE_ACCESS_KEY"]}

    describe "when empty" do
      subject {lambda {SauceWhisk.password}}

      around do |spec|
        @pw = ENV["SAUCE_ACCESS_KEY"]
        ENV.delete "SAUCE_ACCESS_KEY"
        
        spec.run

        ENV["SAUCE_ACCESS_KEY"] = @pw
      end

      it {is_expected.to raise_exception ArgumentError}
    end  
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

    it "defaults to STDOUT" do
      SauceWhisk.logger = nil
      expect( SauceWhisk.logger ).to be_a_kind_of Logger
    end
  end

  describe "##asset_fetch_retries" do
    before :each do
      SauceWhisk.instance_variable_set(:@asset_fetch_retries, nil)
    end

    it "defaults to 1" do
      expect( SauceWhisk.asset_fetch_retries ).to equal 1
    end

    describe "when a Sauce.config is available" do
      before :each do
        SauceWhisk.instance_variable_set(:@asset_fetch_retries, nil)
        mock_config = Class.new(Hash) do
          def initialize
            self.store(:asset_fetch_retries, 3)
          end
        end
        stub_const "::Sauce::Config", mock_config
      end

      it "tries to read from Sauce.config" do
        expect( SauceWhisk.asset_fetch_retries ).to equal 3
      end

      it "favours values set directly" do
        SauceWhisk.asset_fetch_retries = 4
        expect( SauceWhisk.asset_fetch_retries ).to equal 4
      end
    end

    it "can be set directly" do
      SauceWhisk.asset_fetch_retries = 5
      expect( SauceWhisk.asset_fetch_retries ).to equal 5
    end
  end

  describe "##rest_retries" do
    it "defaults to 1" do
      SauceWhisk.instance_variable_set(:@rest_retries, nil)
      expect( SauceWhisk.rest_retries ).to equal 1
    end

    describe "when a Sauce.config is available" do

      before :each do
        SauceWhisk.instance_variable_set(:@rest_retries, nil)   
        mock_config = Class.new(Hash) do
          def initialize
            self.store(:rest_retries, 3)
          end
        end

        stub_const "::Sauce::Config", mock_config     
      end

      it "tries to read from Sauce.config" do
        expect( SauceWhisk.rest_retries ).to equal 3
      end

      it "favours values set directly" do
        SauceWhisk.rest_retries = 2
        expect( SauceWhisk.rest_retries ).to equal 2
      end
    end
  end
end
