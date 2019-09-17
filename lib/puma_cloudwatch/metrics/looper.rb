class PumaCloudwatch::Metrics
  class Looper
    def self.run(options)
      new(options).run
    end

    def initialize(options)
      @options = options
      @control_url = options[:control_url]
      @control_auth_token = options[:control_auth_token]
      @frequency = Integer(ENV['PUMA_CLOUDWATCH_FREQUENCY'] || 60)
    end

    def run
      raise StandardError, "Puma control app is not activated" if @control_url == nil
      puts "puma-cloudwatch plugin: Will send data every #{@frequency} seconds3."
      Thread.new do
        perform
      end
    end

    def perform
      loop do
        stats = Fetcher.new(@options).call
        results = Parser.new(stats).call
        Sender.new(results).call
        sleep @frequency
      end
    end
  end
end
