require "spec_helper"

describe SauceWhisk::Asset do

  describe "#initialize" do
    let(:data) {"DEDEDEDEDED"}
    let(:name) {"video01.mpg"}
    let(:job_id) {"c4revevegegerg"}
    let(:type) {:video}

    before :each do
      params = {:data => data, :name => name, :type => type, :job_id => job_id}

      @asset = SauceWhisk::Asset.new params
    end

    it "should store the name" do
      expect( @asset.name ).to eq name
    end

    it "should store the data" do
      expect( @asset.data ).to eq data
    end

    it "should store the type" do
      expect( @asset.asset_type ).to eq type
    end

    it "should store the job_id" do
      expect( @asset.job ).to eq job_id
    end
  end

  describe "#type" do
    it "should default to screenshot" do
      expect( SauceWhisk::Asset.new.asset_type ).to eq :screenshot
    end
  end
end