module PumaCloudwatch
  class Metrics
    autoload :Fetcher, "puma_cloudwatch/metrics/fetcher"
    autoload :Parser, "puma_cloudwatch/metrics/parser"

    def self.start_sending(launcher)
      puts "PumaCloudwatch Core start_sending_metrics"
      new(launcher).start_sending
    end

    def initialize(launcher)
      @launcher = launcher

      puts "PumaCloudwatch::Metrics launcher.options #{launcher.options}"
      puts "launcher.options[:workers] #{launcher.options[:workers].inspect}"
      puts "launcher.options[:control_url] #{launcher.options[:control_url].inspect}"
      puts "launcher.options[:control_auth_token] #{launcher.options[:control_auth_token].inspect}"

      @frequency = ENV['PUMA_CLOUDWATCH_FREQUENCY'] || 5 # 30
      @control_url = launcher.options[:control_url]
      @control_auth_token = launcher.options[:control_auth_token]
    end

    def start_sending
      raise StandardError, "Puma control app is not activated" if @control_url == nil
      puts "Sending metrics to CloudWatch..."

      Thread.new do
        loop do
          sleep 1 # at the beginning because it takes a little time for puma to start up
          stats = Fetcher.new(@launcher.options).call
          # pp stats
          Parser.new(@launcher.options, data: stats).call.each do |item|
            puts "item #{item}"
          end

          sleep @frequency
        end
      end
    end
  end
end