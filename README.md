# Tally

[![CircleCI](https://circleci.com/gh/jdtornow/tally.svg?style=svg)](https://circleci.com/gh/jdtornow/tally)

Tally is a simple Rails engine for capturing counts of various activities around an app. These counts are quickly captured in Redis then are archived periodically within the app's default relational database.

Counts are captured in Redis to make them as quick as possible and not slow down your UI with unnecessary database calls.

Tally can be used to capture counts of anything in your app. It is a great local and private alternative to some basic analytics tools. Tally has been used to keep track of pageviews, image impressions, newsletter clicks, new signups, and more. All of Tally's counts are archived on a daily basis, so it makes for easy reporting and trending summaries too.

## Requirements

* Ruby 2.2+
* Rails 5.2.x+
* Redis 4+

## Installation

This gem is a work in process, and only available via Github currently. Installed via bundler in your `Gemfile`:

```ruby
gem "tally", github: "jdtornow/tally"
```

Once the gem is installed, make sure to run `rails db:migrate` to add the `tally_records` table.

## Usage

### Collecting counts

The basic usage of Tally is by incrementing counters. To increment a counter, just use the `Tally.increment` method.

```ruby
# increment the "views" counter by 1
Tally.increment(:views)

# increment the "views" counter by 3
Tally.increment(:views, 3)
```

If you're inside a Rails view, you can capture counts inline too using the `increment_tally` method:

```rails
<div class="some-great-content">
  <% increment_tally :content_views %>
</div>
```

Typically you'd want to do this within a controller, but the view helpers are there to, um help, as needed.

In addition to basic global counters, you can also attach a counter to a specific ActiveRecord model. The `Tally::Countable` mixin can be included in a specific model, or within your `ApplicationRecord` to use globally.

For example, to increment a specific record's views:

```ruby
# in app/models/post.rb
class Post < ApplicationRecord

  include Tally::Countable

end
```

Then, in the controller method where a post is displayed:

```ruby
# in a controller method
class PostsController < ApplicationController

  def show
    @post = Post.find(params[:id])
    @post.increment_tally(:views)
  end

end
```

### Archiving counts

By default all counts are stored in a temporary location within Redis. They can be archived periodically into your primary database. An hourly archive would be reasonable.

To archive counts into the database, run one of the following Rake tasks:

```bash
# archive the current day's records
rails tally:archive

# archive's the previous day's records, useful to run at midnight UTC to capture the previous day's counts
rails tally:archive:yesterday
```

In addition to the rake tasks available, counts can be archived using `Tally::Archiver` with a few more options:

```ruby
# archive current day's records
Tally::Archiver.archive(day: Date.today)

# archive current days's records for a given key
Tally::Archiver.archive(day: Date.today, key: :impressions)

# archive yesterday's records for a given model
Tally::Archiver.archive(day: 1.day.ago, record: Post.first)
```

**Please note that the archiving step is an important one** because by default the counters will expire after a few days in Redis. This is done by design, so your Redis instance doesn't fill up with endless count data.

#### Count expiration

By default, Redis counters are kept for 4 days. To change the default time for Redis counters to be kept, adjust the `ttl` configuration:

```ruby
# keep day counts for 30 days before they automatically expire
Tally.config.ttl = 30.days

# don't expire counts (warning: this may fill up a small redis instance over time)
Tally.config.ttl = nil
```

### Custom archive calculators

In addition to the default archive behavior, Tally can run additional archive classes each time the archive commands above are run. This is useful to perform aggregate calculations or pull stats from other sources to archive.

Custom archive calculators just accept a `Date` to summarize, and then have a `#call` method that returns an array of any new records to archive. Each record should be a hash with a `value` and `key`.

For example, the following calculator does a count of all blog posts as of the given date. This can be useful to show a trending chart over time of the number of posts on a blog:

```ruby
# in config/initializers/tally.rb

# the calculator class is registered as a string so it can be dynamically loaded as needed,
# instead of on boot time
Tally.register_calculator "PostsCountCalculator"
```

Then, somewhere in your app folder likely, would go this class. It doesn't need to go anywhere in particular, but if you have many of them, a folder to organize might be helpful.

```
# app/calculators/posts_count_calculator.rb
class PostsCountCalculator

  include Tally::Calculator

  def call
    posts = Post.where("created_at <= ?", day.end_of_day).count

    {
      key: :posts_count,
      value: posts
    }
  end

end
```

By default, calculators are run in the background using ActiveJob. If you'd prefer to run them inline, set the `perform_calculators` config option to `:now`:

```ruby
Tally.config.perform_calculators = :now
```

### Displaying counts

After the archive commands are run, all counts are placed into the `Tally::Record` model. This is a standard ActiveRecord model that can be used as you see fit.

There are few built-in ways to explore the archived counts in your database. First, the `Tally::RecordSearcher` is a handy tool for finding counts. It just uses ActiveRecord query syntax to build a scope on top of `Tally::Record`.

```ruby
# find all visit records in a given date range
records = Tally::RecordSearcher.search(key: "views", start_date: "2020-01-01", end_date: "2020-01-31")

# find all views for a given post by day
post = Post.first
records = Tally::RecordSearcher.search(key: "views", record: post)
views_by_day = Tally::RecordSearcher.search(key: "views", record: post).group(:day).sum(:value)

# get total views for all posts
Tally::RecordSearcher.search(key: "views", type: "Post").sum(:value)
```

To display counts in a web service, `Tally::Engine` can be mounted to add a few endpoints. Please note that this endpoints are not protected with authentication, so you will want to handle accordingly in your routes with a constraint or something.

```ruby
# in config/routes.rb

mount Tally::Engine, at: "/tally"
```

This adds the following routes to your app:

```text
   recordable_days GET  /days/:type/:id(.:format)    tally/days#index
              days GET  /days(.:format)              tally/days#index
   recordable_keys GET  /keys/:type/:id(.:format)    tally/keys#index
              keys GET  /keys(.:format)              tally/keys#index
recordable_records GET  /records/:type/:id(.:format) tally/records#index
           records GET  /records(.:format)           tally/records#index
```

The endpoints can be used to display JSON-formatted data from `Tally::Record`. These endpoints are useful for turning stats into charts or other formatted data in your front-end. The endpoints are entirely optional, and aren't included by default.

## Redis Connection

Tally works _really_ well with [Sidekiq](https://github.com/mperham/sidekiq/), but it isn't required. If Sidekiq is installed in your app, Tally will use its connection pooling for Redis connections. If Sidekiq isn't in use, the `Redis.current` connection is used to store stats. If you'd like to override the specific connection used for Tally's redis store, you can do so by setting `Tally.redis_connection` to another instance of `Redis`. This can be useful to use an alternate Redis store for just stats, for example.

```ruby
# use an alternate Redis connection (for non-sidekiq integrations)
Tally.redis_connection = Redis.new(...)
```
## Issues

If you have any issues or find bugs running Tally, please [report them on Github](https://github.com/jdtornow/tally/issues).

## License

Tally is released under the [MIT license](http://www.opensource.org/licenses/MIT)

Contributions and pull-requests are more than welcome.
