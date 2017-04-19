require "spec_helper"

describe SauceWhisk::Accounts, :vcr => {:cassette_name => "accounts", :match_requests_on => [:uri, :body]} do
  let(:auth) {"#{ENV["SAUCE_USERNAME"]}:#{ENV["SAUCE_ACCESS_KEY"]}"}

  describe "#fetch" do
    it "fetches the passed in account" do
      SauceWhisk::Accounts.fetch ENV["SAUCE_USERNAME"]
      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/users/#{ENV["SAUCE_USERNAME"]}"
    end

    it "returns an Account object" do
      username = ENV["SAUCE_USERNAME"]
      account = SauceWhisk::Accounts.fetch(username)
      expect( account ).to be_an_instance_of SauceWhisk::Account

      expect( account.username) .to eq username
      expect( account.access_key ).to_not be_nil
    end

    it "includes the concurrency by default" do
      account = SauceWhisk::Accounts.fetch ENV["SAUCE_USERNAME"]
      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/#{ENV["SAUCE_USERNAME"]}/limits"
      expect( account.total_concurrency ).to eq 20
      expect( account.mac_concurrency ).to eq 5
    end

    it "should not include concurrency when conservative is set to false" do
      account = SauceWhisk::Accounts.fetch(ENV["SAUCE_USERNAME"], false)
      assert_not_requested :get, "https://#{auth}@saucelabs.com/rest/v1/#{ENV["SAUCE_USERNAME"]}/limits"
      expect( account.total_concurrency ).to be_nil
    end

    context "with an invalid account" do
      it "Raises an InvalidAccountError" do
        expect{
          SauceWhisk::Accounts.fetch "IDontExist"
        }.to raise_error SauceWhisk::InvalidAccountError
      end
    end
  end

  describe "#concurrency_for" do
    it "fetches the concurrency for the passed in account" do
      SauceWhisk::Accounts.concurrency_for ENV["SAUCE_USERNAME"]
      assert_requested :get, "https://#{auth}@saucelabs.com/rest/v1/#{ENV["SAUCE_USERNAME"]}/limits"
    end

    it "returns concurrencies with altered names" do
      expected_hash = {:mac_concurrency => 5, :total_concurrency => 20}
      expect(SauceWhisk::Accounts.concurrency_for(ENV["SAUCE_USERNAME"])).to eq expected_hash
    end

    it "returns just mac as an integer when requested" do
      expect(SauceWhisk::Accounts.concurrency_for(ENV["SAUCE_USERNAME"], :mac)).to eq 5
    end

    it "returns just the total as an integer when requested" do
      expect(SauceWhisk::Accounts.concurrency_for(ENV["SAUCE_USERNAME"], :total)).to eq 20
    end
  end

  describe "#create_subaccount" do
    let(:params) {{
      :username => "newsub77",
      :password => "davesdisease",
      :name => "Manny",
      :email => "Manny@blackbooks.co.uk"
    }}

    let(:parent) {SauceWhisk::Account.new(:access_key => 12345, :minutes => 23, :id => ENV["SAUCE_USERNAME"])}

    it "calls the correct url" do
      SauceWhisk::Accounts.create_subaccount(parent,
          "Manny", "newsub77", "Manny@blackbooks.co.uk", "davesdisease")

      assert_requested(:post,
        "https://#{auth}@saucelabs.com/rest/v1/users/#{ENV["SAUCE_USERNAME"]}",
        :body => params.to_json
      )
    end

    it "returns a Subaccount object" do
      sub = SauceWhisk::Accounts.create_subaccount(parent, "Manny", "newsub77",
          "Manny@blackbooks.co.uk", "davesdisease")

      expect( sub ).to be_a_kind_of SauceWhisk::Account
    end

    it "returns a Subaccount, parented to the Parent account" do
      parent = SauceWhisk::Accounts.fetch ENV["SAUCE_USERNAME"]

      sub = SauceWhisk::Accounts.create_subaccount(parent, "Manny", "newsub77",
                                                   "Manny@blackbooks.co.uk", "davesdisease")

      expect( sub.parent ).to be parent
    end

    context "trying to create too many subaccounts" do
      it "should throw SubaccountCreationError" do
       expect{
          SauceWhisk::Accounts.create_subaccount(parent, "Manny", "toomany",
              "Manny@blackbooks.co.uk", "davesdisease")
        }.to raise_error SauceWhisk::SubAccountCreationError
      end
    end

    context "trying to create a subaccount which already exists" do
      it "should throw SubaccountCreationError" do
        expect{
          SauceWhisk::Accounts.create_subaccount(parent, "Manny", "duplicate",
               "Manny@blackbooks.co.uk", "davesdisease")
        }.to raise_error SauceWhisk::SubAccountCreationError
      end
    end

    context "trying to create a subaccount which causes the tree to be too deep" do
      it "should throw SubaccountCreationError" do
        expect{
          SauceWhisk::Accounts.create_subaccount(parent, "Manny", "deeptree",
               "Manny@blackbooks.co.uk", "davesdisease")
        }.to raise_error SauceWhisk::SubAccountCreationError
      end
    end

    context "with a non-existant parent" do
      let(:parent) {SauceWhisk::Account.new(:access_key => 12345, :minutes => 23, :id =>"nopenotaperson")}
      it "should throw SubaccountCreationError" do
        expect{
          SauceWhisk::Accounts.create_subaccount(parent, "Manny", "deeptree",
                                                 "Manny@blackbooks.co.uk", "davesdisease")
        }.to raise_error SauceWhisk::InvalidAccountError
      end
    end
  end
end