# Puma Cloudwatch

A [puma](https://puma.io) plugin that sends puma stats to CloudWatch.

## Usage

Some of the plugin's settings can be controlled with environmental variables.

Env Var | Description | Default Value
--- | --- | ---
PUMA\_CLOUDWATCH\_NAMESPACE | CloudWatch metric namespace | WebServer
PUMA\_CLOUDWATCH\_DIMENSION\_NAME | CloudWatch metric dimension name | App
PUMA\_CLOUDWATCH\_DIMENSION\_VALUE | CloudWatch metric dimension value | puma
PUMA\_CLOUDWATCH\_FREQUENCY | How often to send data to CloudWatch in seconds. | 60
PUMA\_CLOUDWATCH\_NOOP | When set, the plugin prints out the metrics instead of sending them to cloudwatch. | (unset)

### Dimension Value: App Name

You should configure the `PUMA_CLOUDWATCH_DIMENSION_VALUE` env variable to include your application name.
For example, if you're application is named "myapp", this would be a good value to use:

    PUMA_CLOUDWATCH_DIMENSION_VALUE=myapp-puma

Then you can get metrics for your `myapp-puma` app. List of metrics:

* pool_capacity: the number of requests that the server is capable of taking right now.
* max_threads:  preconfigured maximum number of worker threads.
* running: the number of running threads (spawned threads) for any Puma worker.
* backlog: the number of connections in that worker's "todo" set waiting for a worker thread.

The `pool_capacity` metric is important. It can be use to show how busy the server is getting before it reaches capacity.

### Sum and Frequency

If you leave the `PUMA_CLOUDWATCH_FREQUENCY` at its default of 60 seconds and you graph out the `pool_capacity` capacity at a 1-minute period, then a useful CloudWatch statistic is Sum. It'll show available `pool_capacity` for all `myapp-puma` servers.  The Sum of the `pool_threads` shows all available threads.

**Important**: If you change the CloudWatch send frequency, then Sum statistic must be normalized to be useful.  For example, let's say you use `PUMA_CLOUDWATCH_FREQUENCY=30`. Then puma-cloudwatch will send data every 30s. However, if the chart is still using a 1-minute period, then the Sum statistic would "double".  Capacity has not doubled, puma-cloudwatch is just sending twice as much data.  To normalize the Sum in this case, you can set the time period to match the frequency: 30 seconds.

If you use the Average statistic, then you don't have to worry about normalizing. Average already inherently normalized. In this sense, average is simpler.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'puma-cloudwatch'
```

And then execute:

    $ bundle

In your `config/puma.rb`

Add these 2 lines your `config/puma.rb`:

```ruby
activate_control_app
plugin :cloudwatch
```

It activates the puma control rack application, and enables the puma-cloudwatch plugin to send metrics.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/puma_cloudwatch.
