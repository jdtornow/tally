# Tally Changelog

v2.1.0

- Clean up CI usage (removes CircleCI in favor of Github Actions)
- Dropped support for Ruby <3.1
- Dropped support for Rails <7

v2.0.0

- Removed support for `Redis.current` in accordance with its removal from [redis-rb 5.0.0](https://github.com/redis/redis-rb/blob/master/CHANGELOG.md#500)
- Added `Tally.config.redis_options` to pass new Redis connection options
- When not using Sidekiq for Redis, the Redis connection is now pooled using [ConnectionPool](https://github.com/mperham/connection_pool)
- Added `Tally.config.redis_pool_config` to pass options to `ConnectionPool` when not using Sidekiq's Redis connection
- Bug fix: Coerce TTL from a duration into an integer before sending to Redis
- Dropped support for Ruby 2
- Dropped support for Rails 5.2 and 6.0. 6.1 and above are still supported.

The 2.0.0 release should be compatible with 1.0.2 in all areas. The major version number was only incremented in case `Redis.current` was being used intentionally.

v1.0.2

- Support for Rails 7
- Compatibility with [redis v4.6.0](https://github.com/redis/redis-rb/blob/master/CHANGELOG.md#460)

v1.0.1

- Support for Ruby 3

v1.0.0

- Initial release of Tally
