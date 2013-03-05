require "spec_helper"

describe Job do
  let(:job) {Job.new}
  subject {Job.new}

  it {should respond_to :id}

  it {should respond_to :id=}

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
    
  end
end
