require 'puma-cloudwatch'

Puma::Plugin.create do
  def start(launcher)
    puts "puma-cloudwatch/lib/puma/plugin/cloudwatch.rb"

    clustered = (launcher.options[:workers] || 0) > 0

    control_url = launcher.options[:control_url]
    raise StandardError, "Puma control app is not activated" if control_url == nil

    puts "clustered #{clustered.inspect}"
    puts "launcher.options[:workers] #{launcher.options[:workers].inspect}"
    puts "launcher.options[:control_url] #{launcher.options[:control_url].inspect}"
    puts "launcher.options[:control_auth_token] #{launcher.options[:control_auth_token].inspect}"

    pp PumaCloudwatch
    PumaCloudwatch::Metrics.start_sending

    # Yabeda::Puma::Plugin.tap do |puma|
    #   puma.control_url = control_url
    #   puma.control_auth_token = launcher.options[:control_auth_token]
    # end

  end
end