module PumaCloudwatch
  class Metrics
    autoload :Fetcher, "puma_cloudwatch/metrics/fetcher"
    autoload :Looper, "puma_cloudwatch/metrics/looper"
    autoload :Parser, "puma_cloudwatch/metrics/parser"
    autoload :Sender, "puma_cloudwatch/metrics/sender"

    def self.start_sending(launcher)
      new(launcher).start_sending
    end

    def initialize(launcher)
      @launcher = launcher
      # puts "PumaCloudwatch::Metrics launcher.options #{launcher.options}"
      # puts "launcher.options[:workers] #{launcher.options[:workers].inspect}"
      # puts "launcher.options[:control_url] #{launcher.options[:control_url].inspect}"
      # puts "launcher.options[:control_auth_token] #{launcher.options[:control_auth_token].inspect}"
    end

    def start_sending
      Looper.run(@launcher.options)
    end
  end
end