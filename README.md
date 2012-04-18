# Frenetic [![Build Status][travis_status]][travis]

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



### Authentication

Frenetic is going to try and use Basic Auth whether you like it or not. If
that is not required, nothing will probably happen. But its going to send the
header anyway.



### API Description

The API's root URL must respond with a description, much like the
[Spire.io][spire.io] API. This is crucial in order for Frenetic to work. If
Frenetic doesn't know what the API contains, it can't parse any resource
responses.

It is expected that any subclasses of `Frenetic::Resource` will adhere to the
schema defined here.

Example:

```js
{
  "_links":{
    "self":{"href":"/api/"},
    "orders":{"href":"/api/orders"},
  },
  "_embedded":{
    "schema":{
      "_links":{
        "self":{"href":"/api/schema"}
      },
      "order":{
        "description":"A widget order",
        "type":"object",
        "properties":{
          "id":{"type":"integer"},
          "first_name":{"type":"string"},
          "last_name":{"type":"string"},
        }
      }
    }
  }
}
```

This response will be requested by Frenetic whenever a call to
`YourAPI.description` is made. The response is memoized so any future calls
will not trigger another API request.



### API Resources

While HAL+JSON is awesome, not all implementations are perfect. Frenetic
assumes a HAL+JSON response as built by [Roar], which may not be in 100%
compliance.

Example:

```js
{
  "id":1,
  "first_name":"Foo",
  "last_name":"Bar",
  "_links":{
    "self":{"href":"/order/1"},
    "next":{"href":"/order/2"}
  }
}
```

The problem here is that the entire response really should be wrapped in
`"_embedded"` and `"order"` keys.

So until that is fixed, Frenetic will continue to be pig headed and continue
to do the "wrong" thing.

## Installation

Add this line to your application's Gemfile:

    gem 'frenetic'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frenetic




## Usage



### Client Initialization

```ruby
MyAPI = Frenetic.new(
  'url'          => 'https://api.yoursite.com',
  'username'     => 'yourname',
  'password'     => 'yourpassword',
  'headers' => {
    'accept' => 'application/vnd.yoursite-v1.hal+json'
    # Optional
    'user-agent' => 'Your Site's API Client', # Optional custom User Agent, just 'cuz
  }
)
```


### Response Caching

If configured to do so, Frenetic will autotmatically cache appropriate responses
through [Rack::Cache][rack_cache]. Only on-disk stores are supported right now.

Add the following `Rack::Cache` configuration options when initializing Frenetic:

```ruby
MyAPI = Frenetic.new(
  ...
  'cache' => {
    'metastore'   => 'file:/path/to/where/you/want/to/store/files/meta',
    'entitystore' => 'file:/path/to/where/you/want/to/store/files/meta'
  }
)
```

The `cache` options are passed directly to `Rack::Cache`, so anything it
supports can be added to the Hash.



### Making Requests

Once you have created a client instance, you are free to use it however you'd
like.

A Frenetic instance supports any HTTP verb that [Faraday][faraday] has
impletented. This includes GET, POST, PUT, PATCH, and DELETE.



#### Frenetic::Resource

An easier way to make requests for a resource is to have your model inherit from
`Frenetic::Resource`. This makes it a bit easier to encapsulate all of your
resource's API requests into one place.

```ruby
class Order < Frenetic::Resource

  api_client { MyAPI }

  class << self
    def find( id )
      if response = api.get( api.description.links.order.href.gsub('{id}', id.to_s) ) and response.success?
        self.new( response.body )
      else
        raise OrderNotFound, "No Order found for #{id}"
      end
    end
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

When your model is initialized, it will contain attribute readers for every
property defined in your API's schema or description. In theory, this allows an
API to add, remove, or change properties without the need to directly update
your model.



### Interpretting Responses

Any response body returned by a Frenetic generated API call will be returned as
an OpenStruct-like object. This object responds to dot-notation as well as Hash
keys and is enumerable.

```ruby
response.body.resources.orders.first
```

or

```ruby
response.body['_embedded']['orders'][0]
```

For your convenience, certain HAL+JSON keys have been aliased by methods to
make your code a bit more readable:

  * `_embedded` can be referenced as `resources`
  * `_links` can be referenced as `links`
  * `href` can be referenced as `url`




## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[hal_json]: http://stateless.co/hal_specification.html
[spire.io]: http://api.spire.io/
[roar]: https://github.com/apotonick/roar
[faraday]: https://github.com/technoweenie/faraday
[rack_cache]: https://github.com/rtomayko/rack-cache