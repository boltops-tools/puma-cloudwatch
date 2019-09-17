# Hack makes sure exceptions in Threads like the one in looper.rb that reports to CloudWatch gets reported
# instead of silently being swallowed.
# https://bugs.ruby-lang.org/issues/6647
class << Thread
  alias old_new new

  def new(*args, &block)
    old_new(*args) do |*bargs|
      begin
        block.call(*bargs)
      rescue Exception => e
        raise if Thread.abort_on_exception || Thread.current.abort_on_exception
        puts "Thread for block #{block.inspect} terminated with exception: #{e.message}"
        puts e.backtrace.reverse.map {|line| "  #{line}"}
      end
    end
  end
end
