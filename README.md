# Smart Init [![Build Status](https://travis-ci.org/pawurb/smart_init.svg)](https://travis-ci.org/pawurb/smart_init) [![Gem Version](https://badge.fury.io/rb/smart_init.svg)](https://badge.fury.io/rb/smart_init)

Do you find yourself writing a lot of boilerplate code like this?

```ruby
def initialize(network_provider, api_token)
  @network_provider = network_provider
  @api_token = api_token
end

def self.call(network_provider, api_token)
  new(network_provider, api_token).call
end
```

This gem provides a simple DSL for getting rid of it. It offers an alternative to using `Struct.new` which does not check for number of parameters provided in initializer, exposes getters and instantiates unecessary class instances.

**Smart Init** offers a unified API convention for stateless service objects, accepting values in initializer and exposing one public class method `call` which instantiates new objects and accepts arguments passed to initializer.

Check out [this blog post](https://pawelurbanek.com/2018/02/12/ruby-on-rails-service-objects-and-testing-in-isolation/) for my reasoning behind this approach to service object pattern.

## Installation

In your Gemfile

```ruby
gem 'smart_init'
```

## API

You can use it either by extending a module:

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
object = ApiClient.new(network_provider: Faraday.new, api_token: 'secret_token')
# <ApiClient:0x007fa16684ec20 @network_provider=Faraday<...>, @api_token="secret_token">
```

If you omit a required attribute an `ArgumentError` will be thrown:

```ruby
client = ApiClient.new(network_provider: Faraday.new)

# ArgumentError (missing required attribute api_token)
```

### Making the object callable

You can use the `is_callable` method:

```ruby
class Calculator < SmartInit::Base
  initialize_with :data
  is_callable

  def call
    ...
    result
  end
end

Calculator.call(data: data) => result
```

Optionally you can customize a callable method name:

```ruby
class Routine < SmartInit::Base
  initialize_with :params
  is_callable method_name: :run!

  def run!
    ...
  end
end

Routine.run!(params: params)
```

### Default arguments

You can use hash based, default argument values:

```ruby
class Adder < SmartInit::Base
  initialize_with :num_a, num_b: 2
  is_callable

  def call
    num_a + num_b
  end
end

Adder.call(num_a: 2) => 4
Adder.call(num_a: 2, num_b: 3) => 5
```

### Readers access

Contrary to using Struct, by default the reader methods are not publicly exposed:

```ruby
client = ApiClient.new(network_provider: Faraday.new, api_token: 'secret_token')
client.api_token => # NoMethodError (private method `api_token' called for #<ApiClient:0x000..>)
```

Optionally you can make all or subset of readers public using the `public_readers` config option. It accepts `true` or an array of method names as an argument.

```ruby
class PublicApiClient < SmartInit::Base
  initialize_with :network_provider, :api_token, public_readers: true
end

client = PublicApiClient.new(network_provider: Faraday.new, api_token: 'secret_token')
client.network_provider => #<Faraday::Connection:0x000...>
client.api_token => 'secret_token'
```

```ruby
class SemiPublicApiClient < SmartInit::Base
  initialize_with :network_provider, :api_token, public_readers: [:network_provider]
end

client = SemiPublicApiClient.new(network_provider: Faraday.new, api_token: 'secret_token')
client.network_provider => #<Faraday::Connection:0x000...>
client.api_token => 'secret_token' => # NoMethodError (private method `api_token' called for #<SemiPublicApiClient:0x000...>)
```

### Accessors access

Similarly, this is how it would look if you tried to use a writer method:

```ruby
client = ApiClient.new(network_provider: Faraday.new, api_token: 'secret_token')
client.api_token = 'new_token' => # NoMethodError (private method `api_token=' called for #<ApiClient:0x000..>)
```

Optionally you can make all or subset of accessors public using the `public_accessors` config option. It accepts `true` or an array of method names as an argument. This will provide both reader and writer methods publicly.

```ruby
class PublicApiClient < SmartInit::Base
  initialize_with :network_provider, :api_token, public_accessors: true
end

client = PublicApiClient.new(network_provider: Faraday.new, api_token: 'secret_token')
client.network_provider => #<Faraday::Connection:0x000...>
client.network_provider = Typhoeus::Request.new(...) => #<Typhoeus::Request:0x000...>
client.api_token => 'secret_token'
client.api_token = 'new_token' => 'new_token'
```

```ruby
class SemiPublicApiClient < SmartInit::Base
  initialize_with :network_provider, :api_token, public_accessors: [:network_provider]
end

client = SemiPublicApiClient.new(network_provider: Faraday.new, api_token: 'secret_token')
client.network_provider => #<Faraday::Connection:0x000...>
client.network_provider = Typhoeus::Request.new(...) => #<Typhoeus::Request:0x000...>
client.api_token => # NoMethodError (private method `api_token' called for #<SemiPublicApiClient:0x000...>)
client.api_token = 'new_token' => # NoMethodError (undefined method `api_token=' called for #<SemiPublicApiClient:0x000...>)
```

Finally, you can mix them together like this:

```ruby
class PublicReadersSemiPublicAccessorsApiClient < SmartInit::Base
  initialize_with :network_provider, :api_token, :timeout,
                  public_readers: true, public_accessors: [:network_provider]
end

client = PublicReadersSemiPublicAccessorsApiClient.new(
           network_provider: Faraday.new, api_token: 'secret_token', timeout_length: 100
         )
client.network_provider => #<Faraday::Connection:0x000...>
client.network_provider = Typhoeus::Request.new(...) => #<Typhoeus::Request:0x000...>
client.api_token => 'secret_token'
client.api_token = 'new_token' => # NoMethodError (undefined method `api_token=' called for #<SemiPublicApiClient:0x000...>)
client.timeout_length => 100
client.timeout_length = 150 => # NoMethodError (undefined method `timeout_length=' called for #<SemiPublicApiClient:0x000...>)
```

```ruby
class SemiPublicReadersSemiPublicAccessorsApiClient < SmartInit::Base
  initialize_with :network_provider, :api_token, :timeout,
                  public_readers: [:timeout], public_accessors: [:network_provider]
end

client = SemiPublicReadersSemiPublicAccessorsApiClient.new(
           network_provider: Faraday.new, api_token: 'secret_token', timeout_length: 100
         )
client.network_provider => #<Faraday::Connection:0x000...>
client.network_provider = Typhoeus::Request.new(...) => #<Typhoeus::Request:0x000...>
client.api_token => # NoMethodError (private method `api_token' called for #<SemiPublicReadersSemiPublicAccessorsApiClient:0x000...>)
client.api_token = 'new_token' => # NoMethodError (undefined method `api_token=' called for #<SemiPublicReadersSemiPublicAccessorsApiClient:0x000...>)
client.timeout_length => 100
client.timeout_length = 150 => # NoMethodError (undefined method `timeout_length=' called for #<SemiPublicReadersSemiPublicAccessorsApiClient:0x000...>)
```

## Arguments API

Alternatively you can use an API without hash arguments, default values, public readers, or public accessors support:

```ruby
class Calculator < SmartInit::Base
  initialize_with_args :data
  is_callable

  def call
    ...
    result
  end
end

Calculator.call(data) => result
```
