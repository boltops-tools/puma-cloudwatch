require 'puma-cloudwatch'

Puma::Plugin.create do
  def start(launcher)
    PumaCloudwatch::Metrics.start_sending(launcher)
  end
end
