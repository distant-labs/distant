
# Distant Client

## Why?

Active-Rest-Client is dead.

FlexiRest doesn't work for me, and I'm too impatient to step painstakingly slow
through Faraday code to figure out why.

  * Distant uses HTTParty under the hood.
  * If you need to set special headers, it's easy.
  * If you need to disable ssl certificate authentication, it's easy.
  * If you need to enable debugging information, it's easy.
  * If you need to change the data coming to or from your API, it's easy.

## What Not To Do:

**DON'T**

  * Think you can expose database functionality as a REST API. You will be disappointed by performance every time.
  * Use this when another client for the API you want to consume already exists.

## Installation

### In your Gemfile

```ruby
gem 'distant'
```

### Usage

```ruby
Distant.configure do |config|
  config.base_uri = 'https://www.example.com/api/v0'
  config.set_authentication_headers_with do |body|
    {'X-Foo-Api-Key' => ENV['FOO_API_KEY']}
  end
end

class Organization < Distant::Base
  attr_accessor :id, :name
  get :all, '/organizations'
  get :find, '/organizations/:id'
  has_many :networks, '/organizations/:id/networks'
  translate do
    from_hash do |hash|
      recursive_underscore(hash)
    end
    to_hash do |obj|
      {
        id: obj.id,
        fooId: obj.foo_id,
      }
    end
  end
end

class Network < Distant::Base
  attr_accessor :id, :organization_id, :name
  belongs_to :organization
  get :find, '/networks/:id'
  has_many :clients, '/networks/:id/clients'
end

class Client < Distant::Base
  attr_accessor :id, :network_id, :name
  belongs_to :network
  get :find, '/clients/:id'
end

Organization.all.each do |org|
  org.networks.each do |network|
    network.clients.each do |client|
      # DO THE THING
    end
  end
end
```

See [examples](examples) directory for examples of usage.

## RUNNING THE TESTS

### Within Docker

```bash
docker build --no-cache -t distant/base . && \
  docker run -t -v $(pwd):/opt/distant distant/base bundle exec rspec
```

### On your host OS

NOTE: Requires Ruby 2.3.0+

```bash
bundle
bundle exec rspec
```
