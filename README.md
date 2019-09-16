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
PUMA\_CLOUDWATCH\_NOOP | When set, the plugin prints out the params that would be sent to CloudWatch instead of actually sending them. | (unset)

### Dimension Value: App Name

You should configure the `PUMA_CLOUDWATCH_DIMENSION_VALUE` env variable to include your application name.
For example if you're application is named "myapp", this would be a good value to use:

    PUMA_CLOUDWATCH_DIMENSION_VALUE=myapp-puma

Then you can get the metrics for the `pool_capacity` for your `myapp-puma` app.

The most useful CloudWatch statistic is Sum. It tells you all available `pool_capacity` for the `myapp-puma` app.

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

It activates the puma control application, and runs the puma-cloudwatch plugin to send metrics.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/puma_cloudwatch.
