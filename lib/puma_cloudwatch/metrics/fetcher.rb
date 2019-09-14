require "json"
require "socket"

class PumaCloudwatch::Metrics
  class Fetcher
    def initialize(options={})
      @control_url = options[:control_url]
      @control_auth_token = options[:control_auth_token]
    end

    def call
      body = Socket.unix(@control_url.gsub('unix://', '')) do |socket|
        socket.print("GET /stats?token=#{@control_auth_token} HTTP/1.0\r\n\r\n")
        socket.read
      end
      JSON.parse(body.split("\n").last) # stats
    end
  end
end
