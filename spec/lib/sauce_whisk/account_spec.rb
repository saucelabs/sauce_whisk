require "spec_helper"

describe SauceWhisk::Account do
  describe "##new" do
    it "sets any options passed in as a hash" do
      options = {
          :access_key => 12345,
          :minutes => 23,
          :mac_minutes => 11,
          :manual_minutes => 4,
          :mac_manual_minutes => 87,
          :id => "someone"
      }

      test_account = SauceWhisk::Account.new options
      test_account.access_key.should eq 12345
      test_account.minutes.should eq 23
      test_account.mac_minutes.should eq 11
      test_account.manual_minutes.should eq 4
      test_account.mac_manual_minutes.should eq 87
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

  describe "#add_subaccount", :vcr => {:cassette_name => "accounts"} do
    let(:parent) {SauceWhisk::Account.new(:access_key => 12345, :minutes => 23, :id => ENV["SAUCE_USERNAME"])}

    it "creates a subaccount" do
      subaccount = parent.add_subaccount("Manny", "newsub77", "Manny@blackbooks.co.uk", "davesdisease")
    end
  end
end