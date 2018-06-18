# shoc :confused:

minimalistic shortener

## About

Simply written in ruby and using redis, to get things done. [Kurz](https://github.com/oltdaniel/kurz) is the complex version of this.

## Setup

```shell
# Get the code
$ git clone https://github.com/oltdaniel/shoc
$ cd shoc
# Install the dependencies
$ bundle install
# Fire up the application
$ ruby server.rb -p 8080
```

Now visit [localhost:8080](http://localhost:8080) to see something.

## Urls

| url | description |
|-|-|
| `/` | landing page |
| `/urls` | view all urls created by the user |
| `/:url` | redirect to shorten url |
| `/:url/view` | view details about shorten url |
| `/recover` | recover user account by user id _(found at `/urls`)_ |

## Config

You can customize the service by changing the `config.yml`.

```yaml
# Define shoc
shoc:
  domain: example.com # domain for external calls
  host: localhost # localhost (internal) or 0.0.0.0 (external)
  port: 8080
  length:
    links: 2
    users: 16

# Define redis
redis:
  host: localhost
  port: 6379

```

## License

_Just do what you'd like to_

[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/oltdaniel/shoc/blob/master/LICENSE)

#### Credit

[Daniel Oltmanns](https://github.com/oltdaniel) - creator
