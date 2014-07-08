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
      expect( tunnel.id ).to eq "tunnel_id"
      expect( tunnel.owner ).to eq "test_user"
      expect( tunnel.status ).to eq "open"
      expect( tunnel.host ).to eq "yacko.wacko.dot"
      expect( tunnel.creation_time ).to eq params[:creation_time]
    end
  end

  describe "#stop" do
    it "calls the Repository class" do
      tunnel = SauceWhisk::Tunnel.new params
      expect( SauceWhisk::Tunnels ).to receive(:stop).with("tunnel_id")

      tunnel.stop
    end
  end

end