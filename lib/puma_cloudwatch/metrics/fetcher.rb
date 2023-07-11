require "json"
require "socket"
require "net/http"
require "uri"

class PumaCloudwatch::Metrics
  class Fetcher
    def initialize(options={})
      @control_url = options[:control_url]
      @control_auth_token = options[:control_auth_token]
      if ENV['PUMA_CLOUDWATCH_DEBUG']
        puts "puma control_url #{@control_url}"
        puts "puma control_auth_token #{@control_auth_token}"
      end
    end

    def call
      body = with_retries do
        read_data
      end
      JSON.parse(body.split("\n").last) # stats
    end

  private
    def read_data
      if @control_url.start_with?("unix://")
        read_socket
      else # starts with tcp://
        read_http
      end
    end

    def read_http
      http_url = @control_url.sub('tcp://', 'http://')
      url = "#{http_url}/stats?token=#{@control_auth_token}"
      uri = URI.parse(url)
      resp = Net::HTTP.get_response(uri)
      resp.body
    end

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
