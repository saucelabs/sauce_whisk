require "spec_helper"

describe SauceWhisk::Job do
  let(:job) {SauceWhisk::Job.new}
  subject {SauceWhisk::Job.new}

  it {should respond_to :id}

  context "Initialized" do
    let(:params) {{
      "id" => "dsfargeg",
      "owner" => "Dave",
      "status" => "Things",
      "error" => nil,
      "name" => "Test All The RESTS",
      "browser" => "firefox",
      "browser_version" => "18",
      "os" => "Windows 2008",
      "creation_time" => Time.now.to_i,
      "start_time" => Time.now + 4,
      "end_time" => Time.now + 118,
      "video_url" => "http://www.notarealplace.com/somewhere/resource",
      "log_url" => "http://www.underthesea.com/notreally/404",
      "public" => false,
      "tags" => ["ruby", "awesome", "restful"],
      "custom_data" => ""
    }}

    subject {SauceWhisk::Job.new(params)}

    it "sets parameters at init" do
      params.each do |k,v|
        subject.send(k).should eq v
      end
    end

    it "tracks changes to methods" do
      subject.name = "ANewName"
      subject.updated_fields.should include :name

      subject.visibility = true
      subject.updated_fields.should include :visibility
    end

    it "does not track unchanged methods" do
      subject.updated_fields.should_not include :build
    end

    it "has empty updated_fields for new instances" do
      new_job = SauceWhisk::Job.new(params)
      new_job.updated_fields.should eq []
    end

    describe "#save" do
      subject {SauceWhisk::Job.new(params)}

      context "with changed values" do
        before(:each) do
          subject.name = "New_Name"
        end

        it "calls the save method of the SauceWhisk::Jobs object" do
          SauceWhisk::Jobs.should_receive(:save).with(subject)
          subject.save
        end
      end
    end

    describe "#stop" do
      subject {SauceWhisk::Job.new(params.merge({"id" => "3edc8fe6d52645bf931b1003da65af1f"}))}

      it "Calls the correct REST API method", :vcr => {:cassette_name => "jobs"} do
        subject.stop
        assert_requested :put, "https://#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}@saucelabs.com/rest/v1/dylanatsauce/jobs/#{subject.id}/stop"
      end
    end

    describe "parameters" do
      it "lets you set only the parameters which are mutable" do
        [:name, :build, :passed, :tags, :custom_data, :visibility].each do |param|
          changed_value = "Changed#{param}"
          subject.send("#{param}=", changed_value)
          subject.send(param).should eq changed_value
        end
      end

      it "throws an exception if you try to set one of the fixed attributes" do
        [:id, :owner, :browser, :browser_version, :os, :error, :creation_time,
         :start_time, :end_time, :video_url, :log_url
        ].each do |param|
          expect {
            subject.send("#{param}=", "TOTALLYDIFFERENT")
          }.to raise_exception

          subject.send(param).should_not eq "TOTALLYDIFFERENT"
        end
      end
    end
  end

  context "fetched from the API" do
    subject {SauceWhisk::Jobs.fetch "bd9c43dd6b5549f1b942d1d581d98cac"}

    describe "#screenshots", :vcr => {:cassette_name => "assets"} do
      it "contains all the screenshots for that job" do
        subject.screenshots.length.should be 4
      end

      it "contains actual screenshots" do
        subject.screenshots.first.should be_a_kind_of SauceWhisk::Asset
        subject.screenshots.first.asset_type.should eq :screenshot
      end
    end

    describe "#video", :vcr => {:cassette_name => "assets"} do
      it "should be a video asset" do
        subject.video.should be_a_kind_of SauceWhisk::Asset
        subject.video.asset_type.should eq :video
      end
    end
  end
end
