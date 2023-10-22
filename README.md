# ConstantVision

ConstantVision is a gem to avoid constant reference errors during development.
Given a constant and a namespace in which the constant is being referenced, it outputs the referenced constant and possible reference candidates.

## Note: This project is currently in development and is not ready for use.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add constant_vision

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install constant_vision

## Usage

```ruby
# define arbitrary constants
module Zoo
  module Mammals
    module Cats
      class Lion
        # ...
      end
    end
  end
end

module Staff
  module Mammals
    class Cats
      # ...
    end
  end
end

# specify the constant to be examined and the namespace in which the constant is to be referenced
ConstantVision.search('Mammals', 'Zoo::Mammals::Cats::Lion')
# => "origin: Zoo::Mammals, candidates: [\"Zoo::Mammals\", \"Staff::Mammals\"]"

ConstantVision.search('Mammals', 'Staff::Mammals::Cats')
# => "origin: Staff::Mammals, candidates: [\"Zoo::Mammals\", \"Staff::Mammals\"]"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hogucc/constant_vision. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/constant_vision/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
