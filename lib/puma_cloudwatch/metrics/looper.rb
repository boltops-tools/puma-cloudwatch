class PumaCloudwatch::Metrics
  class Looper
    def self.run(options)
      new(options).run
    end

    def initialize(options)
      @options = options
      @control_url = options[:control_url]
      @control_auth_token = options[:control_auth_token]
      @frequency = ENV['PUMA_CLOUDWATCH_FREQUENCY'] || 5 # 30
    end

    def run
      raise StandardError, "Puma control app is not activated" if @control_url == nil
      puts "Sending metrics to CloudWatch..."
      Thread.new do
        perform
      end
    end

    def perform
      loop do
        # TODO: check this to check socket available
        sleep 1 # at the beginning because it takes a little time for puma to start up.

        stats = Fetcher.new(@options).call
        # puts "stats:".color(:yellow)
        # pp stats
        results = Parser.new(workers: @options[:workers], data: stats).call
        puts "results:" #.color(:yellow)
        pp results
        # Sender.new(results).deliver

        sleep @frequency
      end
    end
  end
end
