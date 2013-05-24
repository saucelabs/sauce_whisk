require "spec_helper"

describe Asset do

  describe "#initialize" do
    let(:data) {"DEDEDEDEDED"}
    let(:name) {"video01.mpg"}
    let(:job_id) {"c4revevegegerg"}
    let(:type) {:video}

    before :each do
      params = {:data => data, :name => name, :type => type, :job_id => job_id}

      @asset = Asset.new params
    end

    it "should store the name" do
      @asset.name.should eq name
    end

    it "should store the data" do
      @asset.data.should eq data
    end

    it "should store the type" do
      @asset.asset_type.should eq type
    end

    it "should store the job_id" do
      @asset.job.should eq job_id
    end
  end

  describe "#type" do
    it "should default to screenshot" do
      Asset.new.asset_type.should eq :screenshot
    end
  end
end