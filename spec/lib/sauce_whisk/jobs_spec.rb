require "spec_helper"

describe Jobs do
  describe "#all", :vcr => {:cassette_name => 'jobs'} do

    it "should return an enumerable" do
      Jobs.all.should be_an Enumerable
    end

    it "should return a set of jobs" do
      jobs_found = Jobs.all
      jobs_found.each {|job| job.should be_a Job}
    end
      

  end

  describe "#change_status" do
    before do
      VCR.insert_cassette 'jobs', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end
    it "exists" do
      Jobs.respond_to? :change_status
    end
  end
end
