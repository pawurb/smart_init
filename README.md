# Smart Init [![Build Status](https://travis-ci.org/pawurb/smart_init.svg)](https://travis-ci.org/pawurb/smart_init) [![Gem Version](https://badge.fury.io/rb/smart_init.svg)](http://badge.fury.io/rb/smart_init)

Do you find yourself writing a lot of boilerplate code like that?

``` ruby
def initialize(network_provider, api_token)
  @network_provider = network_provider
  @api_token = api_token
end
```

Gem provides a simple DSL for getting rid of it. It offers an alternative to using `Struct.new` which does not check for number of parameters provided in initializer, exposes getters and instantiates unecessary class instances.

## Installation

In your Gemfile

```ruby
gem 'smart_init'
```

Then you can use it either by extending a module:

```ruby
class ApiClient
  extend SmartInit

  initialize_with :network_provider, :api_token
end

```

or subclassing:

```ruby
class ApiClient < SmartInit::Base
  initialize_with :network_provider, :api_token
end

```

Now you can just:

```ruby
object = ApiClient.new(Faraday.new, 'secret_token')
# <ApiClient:0x007fa16684ec20 @network_provider=Faraday<...>, @api_token="secret_token">
```

You can also use `is_callable` method:


```ruby
class Calculator < SmartInit::Base
  initialize_with :data
  is_callable

  def call
    ...
    result
  end
end

Calculator.call(data) => result
```

It provides a unified api for stateless service objects, accepting values in initializer and exposing one public class method `call` which instantiates new objects and accepts arguments passed to initializer.

