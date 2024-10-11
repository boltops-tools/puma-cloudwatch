# Change Log

All notable changes to this project will be documented in this file.
This project *loosely tries* to adhere to [Semantic Versioning](http://semver.org/).

## [0.5.2] - 2024-10-11
- [#16](https://github.com/tongueroo/puma-cloudwatch/pull/16) feat: permit multiple metric dimensions

## [0.5.1] - 2023-11-13
- [#13](https://github.com/tongueroo/puma-cloudwatch/pull/13) delay error messages until first successful fetch

## [0.5.0] - 2023-07-11
- [#11](https://github.com/tongueroo/puma-cloudwatch/pull/11) Added support for PUMA_CLOUDWATCH_AWS_ACCESS_KEY_ID and PUMA_CLOUDWATCH_AWS_SECRET_ACCESS_KEY env vars to configure an AWS access key
- [#12](https://github.com/tongueroo/puma-cloudwatch/pull/12) http tcp port support also

## [0.4.8] - 2023-02-24
- [#10](https://github.com/tongueroo/puma-cloudwatch/pull/10) fix region if check
- loosen development dependencies

## [0.4.7] - 2023-02-24
- [#9](https://github.com/tongueroo/puma-cloudwatch/pull/9) fix region if check

## [0.4.6] - 2023-01-05
- [#7](https://github.com/tongueroo/puma-cloudwatch/pull/7) Add PUMA_CLOUDWATCH_AWS_REGION

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
