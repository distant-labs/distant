
# BUILD: docker build --no-cache -t distant/base .
# RUN TESTS: docker run -t -v $(pwd):/opt/distant distant/base bundle exec rspec

FROM ruby:2.3.0-alpine
ADD ./ /opt/distant
WORKDIR /opt/distant
RUN set -x && \
    adduser -D ci && \
    chown -R ci:ci /opt/distant && \
    apk add --update --upgrade git build-base
USER ci
RUN bundle install --verbose
