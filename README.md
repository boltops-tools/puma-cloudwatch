# Puma Cloudwatch Plugin

A [puma](https://puma.io) plugin that sends puma stats to CloudWatch.

## Usage

You should configure the `PUMA_CLOUDWATCH_DIMENSION_VALUE` env variable to include your application name.
For example, if you're application is named "myapp", this would be a good value to use:

    PUMA_CLOUDWATCH_DIMENSION_VALUE=myapp-puma

Then you can get metrics for your `myapp-puma` app. List of metrics:

* pool_capacity: the number of requests that the server is capable of taking right now.
* max_threads:  preconfigured maximum number of worker threads.
* running: the number of running threads (spawned threads) for any Puma worker.
* backlog: the number of connections in that worker's "todo" set waiting for a worker thread.

The `pool_capacity` metric is important. It shows how busy the server is getting before it reaches capacity.

### Environment Variables

The plugin's settings can be controlled with environmental variables:

Env Var | Description | Default Value
--- | --- | ---
PUMA\_CLOUDWATCH\_NAMESPACE | CloudWatch metric namespace | WebServer
PUMA\_CLOUDWATCH\_DIMENSION\_NAME | CloudWatch metric dimension name | App
PUMA\_CLOUDWATCH\_DIMENSION\_VALUE | CloudWatch metric dimension value | puma
PUMA\_CLOUDWATCH\_FREQUENCY | How often to send data to CloudWatch in seconds. | 60
PUMA\_CLOUDWATCH\_NOOP | When set, the plugin prints out the metrics instead of sending them to cloudwatch. | (unset)

### Sum and Frequency

If you leave the `PUMA_CLOUDWATCH_FREQUENCY` at its default of 60 seconds and graph out the `pool_capacity` capacity with a 1-minute period resolution, then the CloudWatch Sum statistic is useful. It shows how busy all the `myapp-puma` servers are.  Particularly, the `pool_capacity` shows available capacity,  and  `pool_threads` shows the total threads.

**Important**: If you change the CloudWatch send frequency, then Sum statistic must be normalized.  For example, let's say you use `PUMA_CLOUDWATCH_FREQUENCY=30`. Then puma-cloudwatch will send data every 30s. However, if the chart is still using a 1-minute period, then the Sum statistic would "double".  Capacity has not doubled, puma-cloudwatch is just sending twice as much data.  To normalize the Sum, set the time period resolution to match the frequency. In this case: 30 seconds.

If you use the Average statistic, then you don't have to worry about normalizing. Average is inherently normalized.

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
