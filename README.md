# Puma Cloudwatch Plugin

[![Gem Version](https://badge.fury.io/rb/puma-cloudwatch.svg)](https://badge.fury.io/rb/puma-cloudwatch)

[![BoltOps Badge](https://img.boltops.com/boltops/badges/boltops-badge.png)](https://www.boltops.com)

A [puma](https://puma.io) plugin that sends puma stats to CloudWatch.

## Usage

**Important**: To enable the plugin to send metrics to CloudWatch you must set the `PUMA_CLOUDWATCH_ENABLED` env variable. This allows you to send only metrics on configured servers and not unintentionally send them locally.

It also strongly encourage to set the `PUMA_CLOUDWATCH_DIMENSION_VALUE` env variable to include your application name. For example, if your application is named "demo-web", this would be a good value to use:

    PUMA_CLOUDWATCH_DIMENSION_VALUE=demo-web-puma

Then you can get metrics for your `demo-web-puma` app. List of metrics:

* pool_capacity: the number of requests that the server is capable of taking right now.
* max_threads:  preconfigured maximum number of worker threads.
* running: the number of running threads (spawned threads) for any Puma worker.
* backlog: the number of connections in that worker's "todo" set waiting for a worker thread.

The `pool_capacity` metric is important. It can be used to show how busy the server is getting before it reaches capacity.  The formula is:

    busy_percent = ( 1 - pool_capacity / max_threads ) * 100

### Environment Variables

The plugin's settings can be controlled with environmental variables:

Env Var | Description | Default Value
--- | --- | ---
PUMA\_CLOUDWATCH\_DEBUG | When set, the plugin prints out the metrics that get sent to CloudWatch. | (unset)
PUMA\_CLOUDWATCH\_DIMENSION\_NAME | CloudWatch metric dimension name | App
PUMA\_CLOUDWATCH\_DIMENSION\_VALUE | CloudWatch metric dimension value | puma
PUMA\_CLOUDWATCH\_ENABLED | Enables sending of the data to CloudWatch. | (unset)
PUMA\_CLOUDWATCH\_FREQUENCY | How often to send data to CloudWatch in seconds. | 60
PUMA\_CLOUDWATCH\_NAMESPACE | CloudWatch metric namespace | WebServer
PUMA\_CLOUDWATCH\_AWS\_REGION | CloudWatch metric AWS region | (unset)
PUMA\_CLOUDWATCH\_AWS\_ACCESS_KEY_ID | AWS access key ID | (unset)
PUMA\_CLOUDWATCH\_AWS\_SECRET_ACCESS_KEY | AWS secret access key | (unset)
PUMA\_CLOUDWATCH\_MUTE\_START\_MESSAGE | Mutes the "puma-cloudwatch plugin" startup message | (unset)
PUMA\_CLOUDWATCH\_ENVIRONMENT | CloudWatch environment dimension value | (Puma servers environment)

### Sum and Frequency Normalization

If you leave the `PUMA_CLOUDWATCH_FREQUENCY` at its default of 60 seconds and graph out the `pool_capacity` capacity with a 1-minute period resolution, then the CloudWatch Sum statistic is "normalized" and useful. It shows the overall capacity total of the `demo-web-puma` servers.  Particularly, the `pool_capacity` shows available capacity,  and  `pool_threads` shows the total threads configured.

If you change the CloudWatch send frequency, then Sum statistic must be normalized by changing the period on the chart.  For example, let's say you use `PUMA_CLOUDWATCH_FREQUENCY=30`. Then puma-cloudwatch will send data every 30s. However, if the chart is still using a 1-minute period, then the Sum statistic would "double".  Capacity has not doubled, puma-cloudwatch is just sending twice as much data for that period.  To normalize the Sum, set the time period resolution to match the frequency. In this case: 30 seconds.

If you use the Average statistic, then you don't have to worry about normalizing. Average is inherently normalized.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'puma-cloudwatch'
```

And then execute:

    $ bundle

Add these 2 lines your `config/puma.rb`:

config/puma.rb

```ruby
activate_control_app
plugin :cloudwatch
```

It activates the puma control rack application, and enables the puma-cloudwatch plugin to send metrics.

### More Setup Notes

Make sure that EC2 instance running the puma server has IAM permission to publish to CloudWatch. If you are using ECS, the default permissions for the ECS task should work.

Alternatively, you may configure an AWS Access Key ID and Secret Key with the `PUMA_CLOUDWATCH_AWS_ACCESS_KEY_ID` and `PUMA_CLOUDWATCH_AWS_SECRET_ACCESS_KEY` env variables.

If are you using ECS awsvpc, make sure you have the task running on private subnets with a NAT. From the AWS docs: [Task Networking with the awsvpc Network Mode](https://docs.aws.amazon.com/en_pv/AmazonECS/latest/developerguide/task-networking.html)

> The awsvpc network mode does not provide task ENIs with public IP addresses for tasks that use the EC2 launch type. To access the internet, tasks that use the EC2 launch type must be launched in a private subnet that is configured to use a NAT gateway.

## How It Works: Internal Puma Stats Server

Puma has an internal server that has a stats endpoint. It runs on a unix socket by default. The puma-cloudwatch works by running continuous loop that polls this puma socket.

### Debug Internal Puma Server: Socket

By default, the socket file is a random path and token. You can use `PUMA_CLOUDWATCH_DEBUG` to see the puma `control_url` and `control_auth_token`.

You'll see something like this:

    $ PUMA_CLOUDWATCH_DEBUG=1 rail server
    * Starting control server on unix:///tmp/puma-status-1689096041362-18083
    Use Ctrl-C to stop
    puma control_url unix:///tmp/puma-status-1689096041362-18083
    puma control_auth_token 609a3fe77de470ad87eaaf0a28a4d22d

To test the socket

    echo -e "GET /stats?token=62a21462ce921590337cfe8a2bf53505 HTTP/1.1\r\nHost: localhost\r\n\r\n"  | socat - UNIX-CONNECT:/tmp/puma-status-1689095966545-17509

You can specify the path and disable the token to make it easier:

config/puma.rb

```ruby
activate_control_app "unix://tmp/pumactl.sock", { no_token: true }
# another example with full path, note the additinal beginning /
# activate_control_app "unix:///full/path/tmp/pumactl.sock", { no_token: true }
plugin :cloudwatch
```

Send a stats request to the socket with `socat`

    $ echo -e "GET /stats HTTP/1.1\r\nHost: localhost\r\n\r\n"  | socat - UNIX-CONNECT:tmp/pumactl.sock
    HTTP/1.1 200 OK
    Content-Type: application/json
    Connection: close
    Content-Length: 114

    {"started_at":"2023-07-11T16:32:37Z","backlog":0,"running":5,"pool_capacity":5,"max_threads":5,"requests_count":0}

### Debug Internal Puma Server: TCP Port

You can also use a tcp port instead.

config/puma.rb

```ruby
activate_control_app "tcp://127.0.0.1:9293", { no_token: true }
plugin :cloudwatch
```

You can see the stats with `curl`.

    $ curl "localhost:9293/stats"
    {"started_at":"2023-07-11T17:17:31Z","backlog":0,"running":5,"pool_capacity":5,"max_threads":5,"requests_count":0}

### puma control-url option note

If you're calling puma directly, there's an option to specify the control url and token, example:

    $ puma --control-url tcp://127.0.0.1:9293 --control-token foo
    * Listening on http://0.0.0.0:3000
    * Starting control server on http://127.0.0.1:9293

This conflicts with activate the control app in the puma.rb

config/puma.rb

```ruby
activate_control_app
plugin :cloudwatch
```

So do not use those options when using this puma plugin.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/boltops-tools/puma-cloudwatch
