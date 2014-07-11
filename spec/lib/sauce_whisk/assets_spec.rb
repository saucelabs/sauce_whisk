require "spec_helper"

describe SauceWhisk::Assets do
  let(:auth) {"#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}"}
  let(:user) {ENV["SAUCE_USERNAME"]}

  describe "#fetch", :vcr => {:cassette_name => "assets"} do
    let(:job_id)  {"bd9c43dd6b5549f1b942d1d581d98cac"}
    let(:asset_name)  {"0000screenshot.png"}

    it "fetches an asset for the requested job" do
      SauceWhisk::Assets.fetch job_id, asset_name

      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/#{user}/jobs/#{job_id}/assets/#{asset_name}"
    end

    it "returns an asset" do
      SauceWhisk::Assets.fetch(job_id, asset_name).should be_an_instance_of SauceWhisk::Asset
    end

    it "initializes the asset properly" do
      asset = SauceWhisk::Assets.fetch job_id, asset_name
      expect( asset.name ).to eq asset_name
      expect( asset.job ).to eq job_id
      expect( asset.asset_type ).to eq :screenshot
    end

    context "for an invalid asset" do
      let(:invalid_job_id) {"aaaaaaaaaaaaaaaa"}

      it "returns a RestClient::ResourceNotFound Exception" do
        expect {
          SauceWhisk::Assets.fetch invalid_job_id, asset_name
        }.to raise_error RestClient::ResourceNotFound
      end
    end

    context "for an asset that's not available immediately" do
      let(:slow_job_id) {"n0th3r3y3t"}

      it "returns the asset" do
        SauceWhisk::Assets.fetch(slow_job_id, asset_name).should be_an_instance_of SauceWhisk::Asset
      end
    end
  end
  
  describe "#delete_asset", :vcr => {:cassette_name => "assets"} do
    let(:asset_job_id) {"f7bcec8f706f4910ba128f48e0b8c6c7"}
    it "can delete a job" do
      SauceWhisk::Assets.delete_asset(asset_job_id).should be_an_instance_of SauceWhisk::Asset
    end
  end
  
  describe "#already_deleted_asset", :vcr => {:cassette_name => "assets"} do
    let(:asset_job_id) {"651c7d737b7547e994678d981dcc433c"}
    it "returns nil for already deleted assets" do
      SauceWhisk::Assets.delete_asset(asset_job_id).should be_an_instance_of SauceWhisk::Asset
    end
  end

end