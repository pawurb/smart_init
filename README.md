# SmartInit [![Build Status](https://travis-ci.org/pawurb/smart_init.svg)](https://travis-ci.org/pawurb/smart_init) [![Gem Version](https://badge.fury.io/rb/smart_init.svg)](http://badge.fury.io/rb/smart_init)

Do you find yourself writing a lot of boilerplate code like this?

``` ruby
def initialize(network_provider, api_token)
  @network_provider = network_provider
  @api_token = api_token
end
```

Gem provides a simple DSL for getting rid of it.

## Installation

In your Gemfile

```ruby
gem 'smart_init'
```

Then you can is it either by extending a module:

```ruby
class MyClass
  extend SmartInit

  initialize_with :network_provider, :api_token
end

```

or subclassing:

```ruby
class MyClass < SmartInit::Base
  initialize_with :network_provider, :api_token
end

```


