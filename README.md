# Tally

_NOTE: This gem is a work in process. Use at your own risk!_

[![CircleCI](https://circleci.com/gh/jdtornow/tally.svg?style=svg)](https://circleci.com/gh/jdtornow/tally)

Tally is a simple Rails engine for capturing counts of various activities around an app. These counts are quickly captured in Redis then are archived periodically within the app's default relational database.

Counts are captured in Redis to make them as quick as possible and not slow down your UI with unnecessary database calls.

Tally can be used to capture counts of anything in your app. It is a great local and private alternative to some basic analytics tools. Tally has been used to keep track of pageviews, image impressions, newsletter clicks, new signups, and more. All of Tally's counts are archived on a daily basis, so it makes for easy reporting and trending summaries too.

## Installation

This gem is a work in process, and only available via Github currently. Installed via bundler in your `Gemfile`:

```ruby
gem "tally", github: "jdtornow/tally"
```

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
    posts = Post.where("created_at <= ?", day).count

    [
      {
        key: :posts_count,
        value: posts
      }
    ]
  end

end
```

### Displaying counts

After the archive commands are run, all counts are placed into the `Tally::Record` model. This is a standard ActiveRecord model that can be used as you see fit.

_TODO: Add some more details here about the endpoints available and the data format._

## Issues

If you have any issues or find bugs running Tally, please [report them on Github](https://github.com/jdtornow/tally/issues).

## License

Tally is released under the [MIT license](http://www.opensource.org/licenses/MIT)

Contributions and pull-requests are more than welcome.
