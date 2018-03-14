FROM ruby:2.3.6

ENV DRIVER remote_container

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY repro.rb .

CMD ["ruby", "repro.rb"]
