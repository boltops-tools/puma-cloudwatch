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
    end

    def start_sending
      Looper.run(@launcher.options)
    end
  end
end
