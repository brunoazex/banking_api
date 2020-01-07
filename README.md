# Banking Api

[![Build Status](https://travis-ci.com/brunoazex/banking_api.svg?branch=master)](https://travis-ci.com/brunoazex/banking_api)
[![Coverage Status](https://coveralls.io/repos/github/brunoazex/banking_api/badge.svg?branch=master)](https://coveralls.io/github/brunoazex/banking_api?branch=master)

API Documentation on Swagger: <https://app.swaggerhub.com/apis-docs/brunoazex/banking_api/1.0.0>

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

## Steps to make it production

### Heroku Preparation

On Heroku, only the Banking API app will run in a docker container. The Database will run as a heroku add-on.

To prepare the Heroku app:

    heroku login
    heroku create
    heroku rename <app-name>
e.g.
    heroku rename azex-banking-api

#### Secret key base for app and guardian production

configure SECRET_KEY_BASE and SECRET_GUARDIAN_KEY:

    heroku config:set SECRET_KEY_BASE=$(mix phx.gen.secret)  
    heroku config:set SECRET_GUARDIAN_KEY=$(mix guardian.gen.secret) 

#### Database for production on Heroku

Tell Heroku to use the postgres add-on:

    heroku addons:create heroku-postgresql:hobby-dev

After that, the database is available and the configuration is set in an environment variable, you can check it with

    heroku config:get DATABASE_URL

#### Timber integration

Tell Heroku to use the timber.io add-on:

    heroku addons:create timber-logging:free

Then configure TIMBER_API_KEY and TIMBER_SOURCE_ID

    heroku config:set TIMBER_API_KEY=<replace with your timber api key>
    heroku config:set TIMBER_SOURCE_ID=<replace with your timber source id>

#### Send email notifications with SendGrid integration

Configure SENDGRID_API_KEY

    heroku config:set SENDGRID_API_KEY=<replace with your sendgrid api key>

## Pushing the image to Heroku

### Documentation

* Heroku side: [Container Registry & Runtime (Docker Deploys)](https://devcenter.heroku.com/articles/container-registry-and-runtime)
* Travis side: [Pushing a Docker Image to a Registry](https://docs.travis-ci.com/user/docker/#Pushing-a-Docker-Image-to-a-Registry)

### Making the Heroku API key known to Travis CI

In order to access heroku, the Heroku API key must be set as HEROKU_API_KEY
environment variable in the travis repository.

One way to do that is to obtain the API key and set is via the Travis web
interface under "settings". Be sure to switch "Show in log" to off, otherwise
your key will be included in the log and be public to everyone enabling everyone
to access your Heroku account.

(note: it should also be possible to set the HEROKU_API_KEY via .travis.yml
  add HEROKU_API_KEY to .travis.yml
  travis encrypt HEROKU_API_KEY=$(heroku auth:token) --add env.global
)

### Making the Heroku App name known to Travis CI

You have to SET HEROKU_APP_NAME with heroku app name generated (or renamed) at
Heroku Preparation step in the Travis repository environment settings.

## Making the app to production

Simply commit and push to your github repository and then this flow will happen:

* Travis will detect the new commit and will build it to specifically run tests

* Then tests will be run and get stats sent to Coveralls (getting the cool code coverage badge!)

* After running test successed, Travis will build, deploy, get running the app and 
the database setup/migration on the brand new container now hosted at Heroku :)
