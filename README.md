
# Distant Client

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
  get :all, '/organizations'
  get :find, '/organizations/:id'
  has_many :networks, '/organizations/:id/networks'
end

class Network < Distant::Base
  belongs_to :organization
  get :find, '/networks/:id'
  has_many :clients, '/networks/:id/clients'
end

class Client < Distant::Base
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
