require "spec_helper"

describe SauceWhisk::Assets do
  let(:auth) {"#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}"}

  describe "#fetch", :vcr => {:cassette_name => "assets"} do
    let(:job_id)  {"bd9c43dd6b5549f1b942d1d581d98cac"}
    let(:asset_name)  {"0000screenshot.png"}

    it "fetches an asset for the requested job" do
      SauceWhisk::Assets.fetch job_id, asset_name

      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/jobs/#{job_id}/assets/#{asset_name}"
    end

    it "returns an asset" do
      SauceWhisk::Assets.fetch(job_id, asset_name).should be_an_instance_of SauceWhisk::Asset
    end

    it "initializes the asset properly" do
      asset = SauceWhisk::Assets.fetch job_id, asset_name
      asset.name.should eq asset_name
      asset.job.should eq job_id
      asset.asset_type.should eq :screenshot
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
end