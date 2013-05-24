require "spec_helper"

describe Assets do
  let(:auth) {"#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}"}

  describe "#fetch", :vcr => {:cassette_name => "assets"} do
    let(:job_id)  {"bd9c43dd6b5549f1b942d1d581d98cac"}
    let(:asset_name)  {"0000screenshot.png"}

    it "fetches an asset for the requested job" do
      Assets.fetch job_id, asset_name

      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/jobs/#{job_id}/assets/#{asset_name}"
    end

    it "returns an asset" do
      Assets.fetch(job_id, asset_name).should be_an_instance_of Asset
    end

    it "initializes the asset properly" do
      asset = Assets.fetch job_id, asset_name
      asset.name.should eq asset_name
      asset.job.should eq job_id
      asset.asset_type.should eq :screenshot
    end
  end
end