# Banking Api

[![Build Status](https://travis-ci.com/brunoazex/banking_api.svg?branch=master)](https://travis-ci.com/brunoazex/banking_api)
[![Coverage Status](https://coveralls.io/repos/github/brunoazex/banking_api/badge.svg?branch=master)](https://coveralls.io/github/brunoazex/banking_api?branch=master)

API Documentation on Swagger: https://app.swaggerhub.com/apis-docs/brunoazex/banking_api/0.1.0#/signUp

#### Development
To start server:
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`
  
#### Tests
* Run `mix credo --strict` for code climate
* Run `MIX_ENV=test mix coveralls` for Code test coverage statistics
* Travis CI Builds are available at https://travis-ci.com/brunoazex/banking_api
* Coveralls tests statics are available at https://coveralls.io/github/brunoazex/banking_api

#### Steps to make it production ready:
TODO: Docker configuration
