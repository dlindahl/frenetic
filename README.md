# Frenetic  [![Gem Version][version_badge]][version] [![Build Status][travis_status]][travis]

[version_badge]: https://badge.fury.io/rb/frenetic.png
[version]: http://badge.fury.io/rb/frenetic
[travis_status]: https://secure.travis-ci.org/dlindahl/frenetic.png
[travis]: http://travis-ci.org/dlindahl/frenetic

An opinionated Ruby-based Hypermedia API (HAL+JSON) client.



## About

fre&bull;net&bull;ic |frəˈnetik|<br/>
adjective<br/>
fast and energetic in a rather wild and uncontrolled way : *a frenetic pace of activity.*

So basically, this is a crazy way to interact with your Hypermedia HAL+JSON API.

Get it? *Hypermedia*?

*Hyper*?

...

If you have not implemented a HAL+JSON API, then this will not work very well for you.





## Opinions

Like I said, it is opinionated. It is so opinionated, it is probably the biggest
a-hole you've ever met.

Maybe in time, if you teach it, it will become more open-minded.


### HAL+JSON Content Type

Frenetic expects all responses to be in [HAL+JSON][hal_json]. It chose that
standard because it is trying to make JSON API's respond in a predictable
manner, which it thinks is an awesome idea.


### API Description

The API's root URL must respond with a description, much like the
[Spire.io][spire.io] API.

This is crucial in order for Frenetic to work. If Frenetic doesn't know what
the API contains, it can't navigate around it or parse any of it's responses.

**Example:**

```js
// GET http://example.com/api
{
  "_links": {
    "self": {
      "href": "/api/"
    },
    "orders": {
      "href":"/api/orders"
    },
    "order": {
      "href": "/api/orders/{id}",
      "templated": true
    }
  },
  "_embedded": {
    "schema": {
      "_links": {
        "self": { "href":"/api/schema" }
      },
      "order": {
        "description": "A widget order",
        "type": "object",
        "properties": {
          "id": { "type":"integer" },
          "first_name": { "type":"string" },
          "last_name": { "type":"string" },
        }
      }
    }
  }
}
```

This response will be requested by Frenetic whenever a call to
`YourAPI.description` is made.

**Note:** It is highly advised that your API return Cache-Control headers in
this response. Frenetic needs to frequently refer to the API description to see
what is possible. This will result in lots of HTTP requests if you don't tell
it how long to wait before checking again.

If the API does return Cache-Control headers, Frenetic will always cache this
response regardless of which caching middleware you have configured or even if
you have caching disabled.

If you have no control over the API, refer to the
[Default Root Cache Age][root_cache] section.




## New in Version 0.0.20

Version 0.0.20 features a complete top-to-bottom rewrite. Mostly this removes
a lot of the meta-programming magic that I previously used to created Ruby
object representations of resources.

The overall API should remain pretty similar, but there may be some spots that
are different.

In general, writing custom `Frenetic::Resource`s should require *a lot* less
code now as Frenetic handles the common use cases for you.

### TODO Items

* Support `POST`
* Support `PUT`
* Support `PATCH`
* Support `DELETE`





## Configuring

### Client Initialization

Initializing an API client is really easy:

```ruby
class MyApiClient
  # Arbitrary example
  def self.api
    @api ||= Frenetic.new(url:'http://example.com/api')
  end
end
```

At the bare minimum, Frenetic only needs to know what the URL of your API is.


### Configuring

Configuring Frenetic can be done during instantiation:

```ruby
Frenetic.new(url:'http://example.com', api_token:'123bada55k3y')
```

Or with a block:

```ruby
f = Frenetic.new
f.configure do |cfg|
  cfg.url = 'http://example.com'
  cfg.api_token = '123bada55key'
end
```

Or both...

```ruby
f = Frenetic.new(url:'http://example.com')
f.configure do |cfg|
  cfg.api_token = '123bada55key'
end
```

#### Authentication

Frenetic supports both Basic Auth and Token Auth via the appropriate Faraday
middleware.

##### Basic Auth

To use Basic Auth, simply configure Frenetic with a `username` and `password`:

```ruby
Frenetic.new(url:url, username:'user', password:'password')
```

If your API uses an App ID and API Key pair, you can pass those as well:

```ruby
Frenetic.new(url:url, app_id:'123abcSHA1', api_key:'bada55SHA1k3y')
```

The `app_id` and `api_key` values are simply aliases to `username` and
`password`

##### Token Auth

To use Token Auth, simply configure Frenetic with your token:

```ruby
Frenetic.new(url:url, api_token:'bada55SHA1t0k3n')
```


#### Response Caching

If configured to do so, Frenetic will autotmatically cache API responses.

*It is highly recommended that you turn this feature on!*

##### Rack::Cache

```ruby
Frenetic.new(url:url, cache: :rack)
```

Passing in a cache option of `:rack` will cause Frenetic to use Faraday's
`Rack::Cache` middleware with a set of sane default configuration options.

If you wish to provide your own configuration options:

```ruby
Frenetic.new({
  url: url,
  cache: {
    metastore:     'file:tmp/rack/meta',
    entitystore:   'file:tmp/rack/body',
    ignore_headers: %w{Authorization Set-Cookie X-Content-Digest}
  }})
```

Any key/value pair contained in the `cache` hash will be passed directly onto
the Rack::Cache middleware.

##### Memcached

**TODO**


#### Faraday Adapters

By default, Frenetic is configured to use Faraday's default adapter (usually
Net::HTTP). You can change this with the `adapter` option:

```ruby
Frenetic.new(url:url, adapter: :patron)
```

Frenetic accepts any of the [Faraday adapter shortcuts][adapters], or an instance
of the adapter itself:

```ruby
Frenetic.new(url:url, adapter:Faraday::Adapter::Patron)
```


#### Default Root Cache Age

If you have no control over the API, you can explicitly tell Frenetic how long
to cache the API description for:

```ruby
Frenetic.new(url:url, default_root_cache_age:1.hour)
```



#### Faraday Middleware

Frenetic will yield its internal Faraday connection during initialization:

```ruby
Frenetic.new(url:url) do |builder|
  # `builder` is the Faraday Connection instance with which you can
  # add additional Faraday Middlewares or tweak the configuration.
end
```

You can then use the `builder` object as you see fit.




## Usage

Once you have created a client instance, you are free to use it however you'd
like.

A Frenetic instance supports any HTTP verb that [Faraday][faraday] has
impletented. This includes GET, POST, PUT, PATCH, and DELETE.

```ruby
api = Frenetic.new(url:url)

api.get '/my_things/1'
# { 'id' => 1, 'name' => 'My Thing', '_links' => { 'self' { 'href' => '/api/my_things/1' } } }
```

### Frenetic::Resource

An easier way to make requests for a resource is to create an object that
inherits from `Frenetic::Resource`.

Not only does `Frenetic::Resource` handle the parsing of the raw API response
into a Ruby object, but it also makes it a bit easier to encapsulate all of your
resource's API requests into one place.

```ruby
class Order < Frenetic::Resource

  api_client { MyAPI }

  # TODO: Write a better example for this.
  def self.find_all_by_name(name)
    api.get(search_url(name)) and response.success?
  end
end
```

The `api_client` class method merely tells `Frenetic::Resource` which API Client
instance to use. If you lazily instantiate your client, then you should pass a
block as demonstrated above.

Otherwise, you may pass by reference:

```ruby
class Order < Frenetic::Resource
  api_client MyAPI
end
```

When your model is initialized, it will contain getter methods for every
property defined in your API's schema/description.

Each time a request is made for a resource, Frenetic checks the API to see if
the schema has changed. If so, it will redefine the the getter methods available
on your Class. This is what Hypermedia APIs are all about, a loose coupling
between client and server.

#### Requesting Resources

Given the above `Order` example, and a supporting API, you can query the API
like so:

```ruby
> Order.find(1)
# <Order id=1 total=54.47>

> Order.find_by(id:1)
# <Order id=1 total=54.47>

> Order.find_by!(id:-1, state:'active')
# Frenetic::ResourceNotFound: Couldn't find Order with id=-1, state=active

> Order.find_by(id:-1)
# nil

> Order.all
# [<Order id=1 total=54.47>,<Order id=2 total=42.00>]
```

#### Mocking Resources

Sometimes, when you are writing tests for your API client, it is helpful to have
a mock instance of your API resource to play with.

Frenetic provides a mixin that removes some of the HTTP interactions required
when interacting with a Hypermedia API. It essentially turns your resource
into a fancy OpenStruct, allowing you to assign whatever attributes you want.

You can enable this by directly mixing in the behavior into your resource:

```ruby
require 'frenetic/resource_mockery'

MyResource.send :include, Frenetic::ResourceMockery
```

Or by creating a special Class specifically for testing (which is recommended)

```ruby
# models/my_mock_resource.rb
require 'frenetic/resource_mockery'

class MyMockResource < MyResource
  include Frenetic::ResourceMockery

  def default_attributes
    {
      name: 'Mock Name',
      city: 'Mock City'
    }
  end
end

# spec/integrations/my_integration_spec.rb
describe 'My contrived integration test' do
  it 'returns a Resource' do
    MyResource.stub(:find).and_return MyMockResource.new city:'Washington, DC'

    do_my_thing

    payee.city.should == 'Washington, DC'
  end
end
```

As you can see, this allows you to supply some default values for the attributes
of your resource to ease object creation in testing.



### Integration Testing

When it comes time to write integration tests for your API client, you can either
stub out all of the HTTP requests with something like WebMock or VCR, or you can
use Frenetic in `test_mode`

```ruby
Frenetic.new(url:url, test_mode:true)
# ...or...
api = Frenetic.new(url:url)
api.config.test_mode = true
```

Doing so will allow `Frenetic::Resource.find` to return a mock resource instead
of querying your API for what is available.

Example:

```ruby
class MyResource < Frenetic::Resource
  api_client { Frenetic.new(url) }
end

class MyMockResource < MyResource
  include Frenetic::ResourceMockery
end

> MyResource.api_client.config.test_mode = true
# true
> MyResource.find(99)
# <MyMockResource id=99>
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

I would love to hear how other people are using this (if at all) and am open to
ideas on how to support other Hypermedia formats like [Collection+JSON][coll_json].

[hal_json]: http://stateless.co/hal_specification.html
[spire.io]: http://api.spire.io/
[caching]: #response-caching
[faraday]: https://github.com/technoweenie/faraday
[root_cache]: #default-root-cache-age
[adapters]: https://github.com/lostisland/faraday/blob/c26a060acdd9eae356409c2ca79f1c22f8263de9/lib/faraday/adapter.rb#L7-L17
[rack_cache]: https://github.com/rtomayko/rack-cache
[coll_json]: http://amundsen.com/media-types/collection/
