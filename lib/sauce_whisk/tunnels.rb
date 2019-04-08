require 'sauce_whisk/rest_request_builder'

module SauceWhisk
  class Tunnels
    extend RestRequestBuilder

    def self.resource
      "#{SauceWhisk.username}/tunnels"
    end

    def self.all(opts = {:fetch_each => true})
      all_tunnels = JSON.parse get
      fetch_each = opts[:fetch_each]

      unless fetch_each
        return all_tunnels
      end

      tunnels = all_tunnels.map do |tunnel|
        fetch tunnel
      end

      return tunnels
    end

    def self.open(opts, wait_until_ready = true)
      new_tunnel_parameters = JSON.parse((post :payload => opts), :symbolize_names => true)
      new_tunnel = fetch new_tunnel_parameters[:id]

      while(["starting", "booting"].include? new_tunnel.status)

        new_tunnel = fetch new_tunnel_parameters[:id]
      end

      return new_tunnel
    end

    def self.stop tunnel_id
      delete tunnel_id
    end

    def self.fetch tunnel_id
      unless tunnel_id
        raise ArgumentError, "Can't fetch a tunnel without an id (you provided blank or nil)"
      end
      tunnel_parameters = JSON.parse(get(tunnel_id), :symbolize_names => true)
      Tunnel.new tunnel_parameters
    end
  end

  class Tunnel
    attr_reader :id, :owner, :status, :host, :creation_time, :ssh_port, :tunnel_identifier

    def initialize(params)
      params.each do |param, val|
        self.instance_variable_set("@#{param}", val)
      end
    end

    def stop
      SauceWhisk::Tunnels.stop self.id
    end
  end
end
