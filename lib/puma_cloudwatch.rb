require "puma_cloudwatch/version"

module PumaCloudwatch
  class Error < StandardError; end

  autoload :Metrics, "puma_cloudwatch/metrics"
end
