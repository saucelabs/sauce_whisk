require "spec_helper"

describe SauceWhisk::Account do
  describe "#new" do
    it "sets any options passed in as a hash" do
      options = {
          :access_key => 12345,
          :minutes => 23,
          :id => "someone"
      }

      test_account = SauceWhisk::Account.new options
      test_account.access_key.should eq 12345
      test_account.minutes.should eq 23
      test_account.username.should eq "someone"
    end

    it "sets concurrency figures" do
      concurrencies = {
          :mac_concurrency => 23,
          :total_concurrency => 100
      }

      test_account = SauceWhisk::Account.new concurrencies
      test_account.mac_concurrency.should eq 23
      test_account.total_concurrency.should eq 100
    end
  end
end