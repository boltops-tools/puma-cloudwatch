class PumaCloudwatch::Metrics
  class Parser
    METRICS = [:backlog, :running, :pool_capacity, :max_threads]
    # CLUSTERED_METRICS = [:booted_workers, :old_workers]

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
          item[metric] += [status[metric.to_s]]
        end
      end
      result << item
      result
    end

    # def parse(stats, labels = {}, result)
    #   pp stats
    #   stats.each do |key, value|
    #     value.each { |s| parse(s, labels.merge(index: s['index']), result) } if key == 'worker_status'
    #     parse(value, labels, result) if key == 'last_status'
    #     result << {name: key, value: value, labels: labels} if metric?(key)
    #   end
    # end
  end
end
