require "spec_helper"

describe Job do
  let(:job) {Job.new}
  subject {Job.new}

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
      "tags" => ["ruby", "awesome", "restful"]
    }}

    subject {Job.new(params)}

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
      new_job = Job.new(params)
      new_job.updated_fields.should eq []
    end

    describe "#save" do
      subject {Job.new(params)}

      context "with changed values" do
        before(:each) do
          subject.name = "New_Name"
        end

        it "calls the save method of the Jobs object" do
          Jobs.should_receive(:save).with(subject)
          subject.save
        end
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
end
