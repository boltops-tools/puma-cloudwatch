class PumaCloudwatch::Metrics
  class Parser
    METRICS = [:backlog, :running, :pool_capacity, :max_threads, :workers]
    CLUSTERED_METRICS = [:booted_workers, :old_workers]

    def initialize(options, data:)
      @clustered = (options[:workers] || 0) > 0
      @data = data
      puts "clustered #{@clustered.inspect}"
    end

    def call
      Array.new.tap { |result| parse(@data, result) }
    end

  private
    def parse(stats, labels = {}, result)
      stats.each do |key, value|
        value.each { |s| parse(s, labels.merge(index: s['index']), result) } if key == 'worker_status'
        parse(value, labels, result) if key == 'last_status'
        result << {name: key, value: value, labels: labels} if metric?(key)
      end
    end

    def metric?(name)
      METRICS.include?(name.to_sym) || (CLUSTERED_METRICS.include?(name.to_sym) && @clustered)
    end
  end
end
