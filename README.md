# Tally

Tally is a simple Rails engine for capturing counts of various activities around an app. These counts are quickly captured in Redis then are archived periodically within the app's default relational database.

## Installation

This gem is a work in process, and only available via Github currently. Installed via bundler in your `Gemfile`:

```ruby
gem "tally", github: "jdtornow/tally"
```

## Usage

### Collecting counts

To increment a counter, just use the `Tally.increment` method.

```ruby
# increment the "views" counter by 1
Tally.increment(:views)

# increment the "views" counter by 3
Tally.increment(:views, 3)
```

In addition to basic global counters, you can also attach a counter to a specific ActiveRecord model. The `Tally::Countable` mixin can be included in a specific model, or within your `ApplicationRecord` to use globally.

For example, to increment a specific record's views:

```ruby
# in app/models/post.rb
class Post < ApplicationRecord

  include Tally::Countable

end

# in a controller method
class Posts

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


# in another file in your app code somewhere, maybe `app/calculators/posts_count_calculator.rb`
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
