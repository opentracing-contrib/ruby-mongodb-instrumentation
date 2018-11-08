# Mongodb::Instrumentation

This gem provides auto-instrumentation for the MongoDB Ruby Driver by subscribing to Monitoring notifications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mongodb-instrumentation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mongodb-instrumentation

## Usage

To enable instrumentation, simply add this line of code:

```ruby
require 'mongodb/instrumentation'

MongoDB::Instrumentation.instrument
```

The `instrument` method optionally takes a `tracer` argument to explicitly
set the tracer to use. If not provided, the instrumentation will default to the
OpenTracing global tracer.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Unit tests

Run the RSpec tests with

```bash
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/signalfx/ruby-mongodb-instrumentation.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
