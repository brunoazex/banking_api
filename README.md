# Banking Api

[![Build Status](https://travis-ci.com/brunoazex/banking_api.svg?branch=master)](https://travis-ci.com/brunoazex/banking_api)
[![Coverage Status](https://coveralls.io/repos/github/brunoazex/banking_api/badge.svg?branch=master)](https://coveralls.io/github/brunoazex/banking_api?branch=master)

API Documentation on Swagger: <https://app.swaggerhub.com/apis-docs/brunoazex/banking_api/0.1.0#/signUp>

## Development

To start server:

* Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`
  
## Tests

* Run `mix credo --strict` for code climate
* Run `MIX_ENV=test mix coveralls` for Code test coverage statistics
* Travis CI Builds are available at <https://travis-ci.com/brunoazex/banking_api>
* Coveralls tests statics are available at <https://coveralls.io/github/brunoazex/banking_api>

## Steps to make it production ready

### Heroku Preparation

On Heroku, only the Banking API app will run in a docker container. The Database will run as a heroku add-on.

To prepare the Heroku app:

    heroku login
    heroku create
    heroku rename <app-name>
e.g.
    heroku rename azex-banking-api

#### Secret key base for production

configure SECRET_KEY_BASE:

    heroku config:set SECRET_KEY_BASE=$(mix phx.gen.secret)

#### Timber integration

You can obtain the Timber API Key at Settings > API Keys and
the Source ID on the Source settings

configure:

    heroku config:set TIMBER_API_KEY=timber api key
    heroku config:set TIMBER_SOURCE_ID=source id

#### Database for production on Heroku

Tell Heroku to use the postgres add-on:

    heroku addons:create heroku-postgresql:hobby-dev

After that, the database is available and the configuration is set in an environment variable, you can check it with

    heroku config:get DATABASE_URL

## Pushing the image to Heroku

### Documentation

* Heroku side: [Container Registry & Runtime (Docker Deploys)](https://devcenter.heroku.com/articles/container-registry-and-runtime)
* Travis side: [Pushing a Docker Image to a Registry](https://docs.travis-ci.com/user/docker/#Pushing-a-Docker-Image-to-a-Registry)

### Making the Heroku API key known to Travis CI

In order to access heroku, the Heroku API key must be set as HEROKU_TOKEN
environment variable in the travis repository.

One way to do that is to obtain the API key and set is via the Travis web
interface under "settings". Be sure to switch "Show in log" to off, otherwise
your key will be included in the log and be public to everyone enabling everyone
to access your Heroku account.

(note: it should also be possible to set the HEROKU_TOKEN via .travis.yml
  add HEROKU_TOKEN to .travis.yml
  travis encrypt HEROKU_TOKEN=$(heroku auth:token) --add env.global
)

#### Add deploy steps to travis.yml

to get the heroku token into a env variable:

set the env variable on travis (switch "show it in the log" to off!)

add these steps to travis.yml:(can also be tested locally)

* docker login -u -p "$HEROKU_TOKEN"  registry.heroku.com

* docker build -t registry.heroku.com/notes/web -f Dockerfile.production .

* docker push registry.heroku.com/notes/web
    docker login -u _-p $HEROKU_TOKEN registry.heroku.com
* heroku run "./bin/banking_api eval 'BankingApi.Release.migrate()'"

<https://devcenter.heroku.com/articles/local-development-with-docker-compose>
