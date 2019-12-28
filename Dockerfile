FROM elixir:1.9.4-alpine as build

# install build dependencies
RUN apk add --update git build-base

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build project
COPY priv priv
COPY lib lib
RUN mix compile

# build release
COPY rel rel
RUN mix release

# prepare release image
FROM alpine:latest AS app
RUN apk add --update bash openssl

RUN mkdir /app
RUN mkdir /app/user
WORKDIR /app/user

COPY --from=build /app/_build/prod/rel/banking_api ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app/user
CMD ["./bin/banking_api", "start"]