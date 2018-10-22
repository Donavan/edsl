# EDSL - Element DSL

This gem implements an extensible DSL for declaring web elements as part of a page object pattern.  The focus of this gem is making it easy add new accessors allowing for more flexibility when creating abstractions.

This gem does not implement the page object pattern, for an implementation of page object using this gem see edsl-pageobject.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'edsl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install edsl

## Usage

Below is an example of how one might extend the DSL to add a new type of element.
 
```ruby
class DateEdit < SimpleDelegatopr
  def value
    Chronic.parse(super)
  end
end

opts = { how: :text_field,           # call text_field to find this type of element
		 assign_method: :set,        # call element.set(value) when we call name=
		 default_method: :value,     # call element.value when we call name
		 presence_method: :present?
		 wrapper_fn: lambda { |ele, _parent| DateEdit.new(ele) }
		 } # call element.present? when we call name?

EDSL.define_accessor(:date_field, opts )
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/edsl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Edsl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/edsl/blob/master/CODE_OF_CONDUCT.md).
