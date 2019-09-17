# Only apply this monkeypatches to ruby 2.3 because a specific project uses 2.3 still.
major, minor, _ = RUBY_VERSION.split('.')
if major == '2' && minor == '3'
  require "puma_cloudwatch/core_ext/thread"
  require "puma_cloudwatch/core_ext/array"
  require "pp"
end
