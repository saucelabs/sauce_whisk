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
      expect( test_account.access_key ).to eq 12345
      expect( test_account.minutes ).to eq 23
      expect( test_account.mac_minutes ).to eq 11
      expect( test_account.manual_minutes ).to eq 4
      expect( test_account.mac_manual_minutes ).to eq 87
      expect( test_account.username ).to eq "someone"
    end

    it "sets concurrency figures" do
      concurrencies = {
          :mac_concurrency => 23,
          :total_concurrency => 100
      }

      test_account = SauceWhisk::Account.new concurrencies
      expect( test_account.mac_concurrency ).to eq 23
      expect( test_account.total_concurrency ).to eq 100
    end
  end

  describe "#add_subaccount", :vcr => {:cassette_name => "accounts"} do
    let(:parent) {SauceWhisk::Account.new(:access_key => 12345, :minutes => 23, :id => ENV["SAUCE_USERNAME"])}

    it "creates a subaccount" do
      subaccount = parent.add_subaccount("Manny", "newsub77", "Manny@blackbooks.co.uk", "davesdisease")
    end
  end
end