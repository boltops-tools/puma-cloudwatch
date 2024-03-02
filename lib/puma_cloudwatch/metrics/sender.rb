require "aws-sdk-cloudwatch"

# It probably makes sense to configure PUMA_CLOUDWATCH_DIMENSION_VALUE to include your application name.
# For example if you're application is named "myapp", this would be a good value to use:
#
#    PUMA_CLOUDWATCH_DIMENSION_VALUE=myapp-puma
#
# Then you can get all the metrics for the pool_capacity for your myapp-puma app.
#
# Summing the metric tells you the total available pool_capacity for the myapp-puma app.
#
class PumaCloudwatch::Metrics
  class Sender
    def initialize(metrics)
      @metrics = metrics
      @namespace = ENV['PUMA_CLOUDWATCH_NAMESPACE'] || "WebServer"
      @dimension_name = ENV['PUMA_CLOUDWATCH_DIMENSION_NAME'] || "App"
      @dimension_value = ENV['PUMA_CLOUDWATCH_DIMENSION_VALUE'] || "puma"
      @dimensions = ENV['PUMA_CLOUDWATCH_DIMENSIONS'].to_s.split(",").map { |d| [:name, :value].zip(d.split(":")).to_h }
      @frequency = Integer(ENV['PUMA_CLOUDWATCH_FREQUENCY'] || 60)
      @enabled = ENV['PUMA_CLOUDWATCH_ENABLED'] || false
      @region = ENV['PUMA_CLOUDWATCH_AWS_REGION']
      @access_key_id = ENV['PUMA_CLOUDWATCH_AWS_ACCESS_KEY_ID']
      @secret_access_key = ENV['PUMA_CLOUDWATCH_AWS_SECRET_ACCESS_KEY']
    end

    def call
      put_metric_data(
        namespace: @namespace,
        metric_data: metric_data,
      )
    end

    # Input @metrics example:
    #
    #     [{:backlog=>[0, 0],
    #     :running=>[0, 0],
    #     :pool_capacity=>[16, 16],
    #     :max_threads=>[16, 16]}]
    #
    # Output example:
    #
    #   [{:metric_name=>"backlog",
    #     :statistic_values=>{:sample_count=>2, :sum=>0, :minimum=>0, :maximum=>0}},
    #   {:metric_name=>"running",
    #     :statistic_values=>{:sample_count=>2, :sum=>0, :minimum=>0, :maximum=>0}},
    #   {:metric_name=>"pool_capacity",
    #     :statistic_values=>{:sample_count=>2, :sum=>32, :minimum=>16, :maximum=>16}},
    #   {:metric_name=>"max_threads",
    #     :statistic_values=>{:sample_count=>2, :sum=>32, :minimum=>16, :maximum=>16}}]
    #
    # Resources:
    # pool_capcity and max_threads are the important metrics
    # https://dev.to/amplifr/monitoring-puma-web-server-with-prometheus-and-grafana-5b5o
    #
    def metric_data
      data = []
      @metrics.each do |metric|
        metric.each do |name, values|
          data << {
            metric_name: name.to_s,
            dimensions: dimensions,
            storage_resolution: @frequency < 60 ? 1 : 60,
            statistic_values: {
              sample_count: values.length,
              sum: values.inject(0) { |sum, el| sum += el },
              minimum: values.min,
              maximum: values.max
            }
          }
        end
      end
      data
    end

    def dimensions
      return @dimensions if @dimensions.any?
      [
        name: @dimension_name,
        value: @dimension_value
      ]
    end

  private
    def put_metric_data(params)
      if ENV['PUMA_CLOUDWATCH_DEBUG']
        message = "sending data to cloudwatch:"
        message = "NOOP: #{message}" unless enabled?
        puts message
        pp params
      end

      if enabled?
        begin
          cloudwatch.put_metric_data(params)
        rescue Aws::CloudWatch::Errors::AccessDenied => e
          puts "WARN: #{e.class} #{e.message}"
          puts "Unable to send metrics to CloudWatch"
        rescue PumaCloudwatch::Error => e
          puts "WARN: #{e.class} #{e.message}"
          puts "Unable to send metrics to CloudWatch"
        end
      end
    end

    def enabled?
      !!@enabled
    end

    def aws_credentials
      return nil if @access_key_id.nil? || @access_key_id.empty? || @secret_access_key.nil? || @secret_access_key.empty?

      @aws_credentials ||= Aws::Credentials.new(
        @access_key_id,
        @secret_access_key
      )
    end

    def cloudwatch
      @cloudwatch ||= Aws::CloudWatch::Client.new({
        region: @region,
        credentials: aws_credentials
      }.compact)
    rescue Aws::Errors::MissingRegionError => e
      # Happens when:
      #   1. ~/.aws/config is not also setup locally
      #   2. On EC2 instance when AWS_REGION not set
      puts "WARN: #{e.class} #{e.message}"
      raise PumaCloudwatch::Error.new(e.message)
    end
  end
end
