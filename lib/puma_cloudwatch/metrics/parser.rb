class PumaCloudwatch::Metrics
  class Parser
    METRICS = [:backlog, :running, :pool_capacity, :max_threads]

    def initialize(data)
      @data = data
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

      clustered = stats.key?("worker_status")
      if clustered
        statuses = stats["worker_status"].map { |s| s["last_status"] } # last_status: Array with worker stats
        statuses.each do |status|
          METRICS.each do |metric|
            count = status[metric.to_s]
            item[metric] += [count] if count
          end
        end
      else # single mode
        METRICS.each do |metric|
          count = stats[metric.to_s]
          item[metric] += [count] if count
        end
      end

      result << item unless item.empty?
      result
    end
  end
end
