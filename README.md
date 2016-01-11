# Commutator

Commutator is a Model object interface for Amazon DynamoDB.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'commutator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install commutator

## Usage

TODO: Needs work

Basic usage example..

```ruby
class Paint
  include Commutator::Model

  table_name "paint_products"

  attribute :name, :hex_color, type: :string
  attribute :created_ts, :updated_at, type: :integer

  validates :name, :hex_color, presence: true

  primary_key hash: :name, range: :created_ts

  before_put_item :prevent_dupes, :add_timestamps

  module Scopes
    def by_hex(hex)
      index_name('hex-index')
      with_key_condition_expression do |expression|
        expression.where('#? = :?', names: %w(hex_color), values: [hex_color.downcase])
      end      
    end
  end
  
  private
  
  def prevent_dupes(options)
    options.condition_expression.where_not do |expression|
      expression.where('name = :?', values: [name])
    end
  end
  
  def add_timestamps(options)
    now = Time.now.to_i
  
    options.item['updated_at'] = now
    options.item['created_at'] ||= now
  end
end

Color.by_hex("#BBAADD").first
Color.create(name: "Black", hex_color: "#000000")
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tablexi/commutator.


## License

The gem is available as open source under the terms of the [Apache License, Version 2.0](http://opensource.org/licenses/Apache-2.0).

