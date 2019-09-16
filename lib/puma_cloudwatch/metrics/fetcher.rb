require "json"
require "socket"

class PumaCloudwatch::Metrics
  class Fetcher
    def initialize(options={})
      @control_url = options[:control_url]
      @control_auth_token = options[:control_auth_token]
    end

    def call
      body = with_retries do
        read_socket
      end
      JSON.parse(body.split("\n").last) # stats
    end

  private
    def read_socket
      Socket.unix(@control_url.gsub('unix://', '')) do |socket|
        socket.print("GET /stats?token=#{@control_auth_token} HTTP/1.0\r\n\r\n")
        socket.read
      end
    end

    def with_retries
      retries, max_attempts = 0, 10
      yield
    rescue Errno::ENOENT => e
      retries += 1
      if retries > max_attempts
        raise e
      end
      puts "retries #{retries} #{e.class} #{e.message}" if ENV['PUMA_CLOUDWATCH_SOCKET_RETRY']
      sleep 1
      retry
    end
  end
end
