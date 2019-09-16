class PumaCloudwatch::Metrics
  class Parser
    METRICS = [:backlog, :running, :pool_capacity, :max_threads]

    def initialize(workers:, data:)
      @clustered = (workers || 0) > 0
      @data = data
      # puts "clustered #{@clustered.inspect}"
    end

    def call
      Array.new.tap { |result| parse(@data, result) }
    end

  private
    # Build this structure:
    #
    #     [{:backlog=>[0, 0],
    #     :running=>[0, 0],
    #     :pool_capacity=>[16, 16],
    #     :max_threads=>[16, 16]}]
    #
    def parse(stats, result)
      item = Hash.new([])
      worker_statuses = stats.dig("worker_status") # cluster mode
      statuses = worker_statuses.map { |s| s["last_status"] } # last_status: Array with worker stats
      statuses.each do |status|
        METRICS.each do |metric|
          count = status[metric.to_s]
          item[metric] += [count] if count
        end
      end
      result << item unless item.empty?
      result
    end
  end
end
