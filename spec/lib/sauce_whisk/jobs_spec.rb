require "spec_helper"

describe Jobs do
  let(:auth) {"#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}"}
  describe "#all", :vcr => {:cassette_name => 'jobs'} do

    it "should return an enumerable" do
      Jobs.all.should be_an Enumerable
    end

    it "should return a set of jobs" do
      jobs_found = Jobs.all
      jobs_found.each {|job| job.should be_a Job}
    end
  end

  describe "##change_status", :vcr => {:cassette_name => "jobs"} do
    let(:pass_string) {{:passed => true}.to_json}
    it "exists" do
      Jobs.respond_to? :change_status
    end

    it "passes a test status to the REST api" do
      job_id = "bd9c43dd6b5549f1b942d1d581d98cac"
      Jobs.change_status job_id, true
      assert_requested :put, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/jobs/#{job_id}", :body => pass_string, :content_type => "application/json"
    end
  end
end
