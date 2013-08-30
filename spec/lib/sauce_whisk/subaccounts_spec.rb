require "spec_helper"

describe "a subaccount" do
  let(:parent) {SauceWhisk::Account.new(:id => ENV["SAUCE_USERNAME"], :access_key => "12345", :minutes=>12)}
  let(:params) {{:access_key => 12345, :minutes => 23, :id => "someone"}}

  it "is an Account object" do
    sub = SauceWhisk::SubAccount.new(parent, params)
    sub.should be_a_kind_of SauceWhisk::Account
  end

  it "takes a parent as a parameter" do
    sub = SauceWhisk::SubAccount.new(parent, params)
    sub.parent.should be parent
  end
end