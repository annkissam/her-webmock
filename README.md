# Her::WebMock

Tired of hand-inputting paths and JSON hashes when Her is so sensible to use?  Her::WebMock is a useful gem for easy Her::Model request stubs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'her-webmock'
```

And then execute:

    $ bundle

## Usage

In your spec_helper or initializer (or wherever you want to mock things) do:

```ruby
require 'her/webmock/model'

::User.extend ::Her::WebMock::Model
```

where User is a Her::Model. Now you can easily stub the requests that you'd normally expect to
be returned on User.find and User.all

```ruby
User.stub_find(User.new(id: 5, name: 'user'))
# equivalent to
stub_request("http://.../users/5").and_return("so much JSON string that includes id 5 and name 'user'")
```

```ruby
# stub for .all
User.stub_all([User.new(id: 5, name: 'user'), User.new(id: 6, name: "anon")])
# passing 'query' & 'headers' - these get passed to WebMock
User.stub_all([User.new(id: 5, name: 'user')], query: { page: 1, per_page: 20 }, headers: { 'Authorization' => "Bearer ..."  })
# merging additional data into the response
User.stub_all([User.new(id: 5, name: 'user')], response_body: { page: 1 })
```

You can also easily define your own stub method matchers:

```ruby
module Mocks
  module User
    include ::Her::WebMock::Model

    def stub_for_resource_type_and_resource_id(issues, resource_type, resource_id)
      query = {
        'search' => {
          'resource_id_eq' => resource_id,
          'resource_type_eq' => resource_type
        }
      }

      stub_all(issues, query: query)
    end

    ...

User.extend Mocks::User
```

## Configuration

If you expect default headers in all your requests, you can configure them in:

```ruby
Her::WebMock.configure do |config|
  config.default_request_test_headers = { 'Authorization' => /Bearer .+/ }
end
```

## TODO
 * Test stub associations
 * Support more association stubs
 * test default_request_test_headers functionality
 * make the stub methods included in a model just stubs that call out to the stub methods
 * Break out the stub components

## Development

Run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/annkissam/her-webmock/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
