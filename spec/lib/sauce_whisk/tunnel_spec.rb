require "spec_helper"

describe SauceWhisk::Tunnel do
  let(:params) {{
    :id => "tunnel_id",
    :owner  => "test_user",
    :status => "open",
    :host => "yacko.wacko.dot",
    :creation_time => Time.now
  }}

  describe "#new" do
    it "sets all parameters passed in" do
      tunnel = SauceWhisk::Tunnel.new params
      tunnel.id.should eq "tunnel_id"
      tunnel.owner.should eq "test_user"
      tunnel.status.should eq "open"
      tunnel.host.should eq "yacko.wacko.dot"
      tunnel.creation_time.should eq params[:creation_time]
    end
  end

  describe "#stop" do
    it "calls the Repository class" do
      tunnel = SauceWhisk::Tunnel.new params
      SauceWhisk::Tunnels.should_receive(:stop).with("tunnel_id")

      tunnel.stop
    end
  end

end