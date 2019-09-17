require "puma_cloudwatch/version"
require "puma_cloudwatch/core_ext"

module PumaCloudwatch
  class Error < StandardError; end

  autoload :Metrics, "puma_cloudwatch/metrics"
end
