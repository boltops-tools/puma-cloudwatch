# Puma Cloudwatch

A [puma](https://puma.io) plugin that sends puma stats to CloudWatch.

## Usage

The CloudWatch metric has these defaults:

Description | Default Value | Configurable Env Var
--- | --- | ---
namespace | WebServer | PUMA\_CLOUDWATCH\_NAMESPACE
dimension name | App | PUMA\_CLOUDWATCH\_DIMENSION\_NAME
dimension value | puma | PUMA\_CLOUDWATCH\_DIMENSION\_VALUE

You should configure the `PUMA_CLOUDWATCH_DIMENSION_VALUE` env variable to include your application name.
For example if you're application is named "myapp", this would be a good value to use:

    PUMA_CLOUDWATCH_DIMENSION_VALUE=myapp-puma

Then you can get the metrics for the `pool_capacity` for your `myapp-puma` app.

The most useful CloudWatch statistic is Sum. It tells you all available `pool_capacity` for the `myapp-puma` app.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'puma_cloudwatch'
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
