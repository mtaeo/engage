FROM elixir:1.12-alpine as build

RUN apk add --no-cache make gcc g++ musl-dev inotify-tools
RUN mkdir /engage
COPY . /engage
WORKDIR /engage

ENV MIX_ENV=dev
ENV SECRET_KEY_BASE=sKATsleyMMC8eO4rZHm7Qb9iDhaKnMV46BEMskn7u9NJNdDqSgjuUe+mDObCxsqx
ENV SECRET_KEY_BASE_TEST=sKATsleyMMC8eO4rZHm7Qb9iDhaKnMV46BEMskn7u9NJNdDqSgjuUe+mDObCxsqx
ENV GITHUB_CLIENT_ID=
ENV GITHUB_CLIENT_SECRET=
ENV GOOGLE_CLIENT_ID=
ENV GOOGLE_CLIENT_SECRET=
ENV DISCORD_CLIENT_ID=
ENV DISCORD_CLIENT_SECRET=
ENV FACEBOOK_CLIENT_ID=
ENV FACEBOOK_CLIENT_SECRET=
ENV TWITTER_CONSUMER_KEY=
ENV TWITTER_CONSUMER_SECRET=
ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=

RUN mix local.hex --force && \
    mix local.rebar --force

RUN rm -Rf _build && \
    rm -Rf deps && \
    mix deps.get && \
    mix compile

EXPOSE 4000
CMD ["sh", "/engage/entrypoint.sh"]