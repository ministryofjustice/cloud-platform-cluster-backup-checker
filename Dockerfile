FROM ruby:2.6.3-alpine

#Install pre-requisites for building unf_ext gem
RUN apk --update add --virtual build_deps \
    build-base ruby-dev libc-dev linux-headers

RUN addgroup -g 1000 -S appgroup && \
    adduser -u 1000 -S appuser -G appgroup

WORKDIR /app

RUN gem install bundler

COPY Gemfile* ./
RUN bundle install

COPY . .

USER 1000

CMD ["ruby", "./bin/access-es-svc.rb"]
