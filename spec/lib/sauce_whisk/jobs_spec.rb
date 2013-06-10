require "spec_helper"

describe SauceWhisk::Jobs do
  let(:auth) {"#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}"}
  describe "#all", :vcr => {:cassette_name => 'jobs'} do

    it "should return an enumerable" do
      SauceWhisk::Jobs.all.should be_an Enumerable
    end

    it "should return a set of jobs" do
      jobs_found = SauceWhisk::Jobs.all
      jobs_found.each {|job| job.should be_a SauceWhisk::Job}
    end
  end

  describe "##change_status", :vcr => {:cassette_name => "jobs"} do
    let(:pass_string) {{:passed => true}.to_json}
    it "exists" do
      SauceWhisk::Jobs.respond_to? :change_status
    end

    it "passes a test status to the REST api" do
      job_id = "bd9c43dd6b5549f1b942d1d581d98cac"
      SauceWhisk::Jobs.change_status job_id, true
      assert_requested :put, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/jobs/#{job_id}", :body => pass_string, :content_type => "application/json"
    end
  end

  describe "##pass_job" do
    it "Calls the API and passes the given job" do
      job_id = "rerfreferf"
      SauceWhisk::Jobs.should_receive(:change_status).with(job_id, true) {}

      SauceWhisk::Jobs.pass_job job_id
    end
  end

  describe "##fail_job" do
    it "Calls change_status to fail the job" do
      job_id = "rcercer"
      SauceWhisk::Jobs.should_receive(:change_status).with(job_id, false) {}

      SauceWhisk::Jobs.fail_job job_id
    end
  end

  describe "##save", :vcr => {:cassette_name => "jobs"} do
    it "sends a put request" do
      job_id = "bd9c43dd6b5549f1b942d1d581d98cac"
      job = SauceWhisk::Job.new({:id => job_id})
      SauceWhisk::Jobs.save (job)
      assert_requested :put, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/jobs/#{job.id}", :body => anything, :content_type => "application/json"
    end

    it "only sends updated information" do
      job_id = "bd9c43dd6b5549f1b942d1d581d98cac"
      job = SauceWhisk::Job.new({:id => job_id})
      job.name = "Updated Name"
      SauceWhisk::Jobs.save (job)
      expected_body = {:name => "Updated Name"}.to_json
      assert_requested :put, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/jobs/#{job.id}", :body => expected_body, :content_type => "application/json"
    end
  end

  describe "##fetch", :vcr => {:cassette_name => "jobs"} do
    let(:job) {SauceWhisk::Jobs.fetch("bd9c43dd6b5549f1b942d1d581d98cac")}

    it "contains the list of screenshots for the job" do
      job.screenshot_urls.should be_a_kind_of Enumerable
      job.screenshot_urls.length.should_not be 0
    end

    it "returns a job when a valid one is fetched" do
      job.should be_an_instance_of SauceWhisk::Job
    end
  end

  describe "##stop", :vcr => {:cassette_name => "jobs"} do
    it "calls the API correctly" do
      SauceWhisk::Jobs.stop "3edc8fe6d52645bf931b1003da65af1f"
      assert_requested :put, "https://#{auth}@saucelabs.com/rest/v1/dylanatsauce/jobs/3edc8fe6d52645bf931b1003da65af1f/stop", :content_type => "application/json"
    end

    it "does something interesting when the job is already stopped" do
      SauceWhisk::Jobs.stop "9591ce8519f043f8b3bea0462923c883"
    end

    it "does something else interesting when the job does not exist" do
      SauceWhisk::Jobs.stop "job_id"
    end

  end
end
