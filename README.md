# Rspec::RoutesCoverage

Rails-RSpec plugin that will track the coverage of routes among your request specs. Intended for massive Rails JSON backends.

## Installation

Add this line to your application's Gemfile:

    gem 'rspec-routes_coverage'

And then execute:

    $ bundle

## Usage

This gem allows tracking both – manual coverage and automatic coverage. Automatic coverage just works – as soon as any route got at least one request it will be considered auto-tested.

To allow manual coverage the gem defines `describe_request` helper. Being an extension of `describe`, this method requires route to be passed. Every route passed to `describe_request` will be considered manually-tested.

spec/requests/items_spec.rb:
```ruby
require 'spec_helper'

describe ItemsController do

  describe_request :index, request_path: '/items', method: 'GET' do
    it 'lists items' do
      get '/items'
      # ...
    end
  end

  # another style:
  describe_request 'GET /items/:id' do
    it 'shows item' do
      get "/items/#{Item.first.id}"
      # ...
    end
  end

end
```

Default gem output looks the following way:

    Routes coverage stats:
      Manually tested: 46/547
          Auto tested: 34/547
              Pending: 467/547

By default it contains no details. To get the complete listing of routes belonging to each category, you can use `LIST_ROUTES_COVERAGE=true` environment option:

    $ LIST_ROUTES_COVERAGE=true rake spec

Alternatively you can run the following Rake task (ships with the gem):

    $ rake spec:requests:with_coverage

## TODO

* Add the possibility to exclude some routes/namespaces from coverage analysis

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

<img src="http://roundlake.ru/assets/logo.png" align="right" />

* Andrew Shaydurov ([@sandrew](https://github.com/sandrew))

## Contributors

* Boris Staal ([@_inossidabile](http://twitter.com/#!/_inossidabile))

## LICENSE

It is free software, and may be redistributed under the terms of MIT license.