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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/puma_cloudwatch.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
