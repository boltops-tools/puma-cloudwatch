# Change Log

All notable changes to this project will be documented in this file.
This project *loosely tries* to adhere to [Semantic Versioning](http://semver.org/).

## [0.4.5] - 2021-11-09
- [#5](https://github.com/boltops-tools/puma-cloudwatch/pull/5) Enabling high-resolution Cloudwatch metrics if frequency is lower tha…

## [0.4.4]
- #4 fix syntax error in older versions of ruby

## [0.4.3]
- #3 Eliminate the need to add Array#sum

## [0.4.2]
- #2 keep looper running on adversities

## [0.4.1]
- #1 empty results breaks cloudwatch put_metric_data

## [0.4.0]
- improve AWS IAM setup and permission errors so Thread loop doesnt stop

## [0.3.1]
- fix PUMA_CLOUDWATCH_MUTE_START_MESSAGE var

## [0.3.0]
- add PUMA\_CLOUDWATCH\_ENABLED env var check
- improve puma-cloudwatch plugin message

## [0.2.0]
- add PUMA\_CLOUDWATCH\_DEBUG flag
- fixes for ruby 2.3
- Update looper.rb puts

## [0.1.0]
- Initial release
