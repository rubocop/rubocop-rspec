FROM alpine:3.4
MAINTAINER John Backus <johncbackus@gmail.com>

# URLs for ruby-install and chruby which help install and manage our ruby matrix
ARG RUBY_INSTALL_URL=https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz
ARG CHRUBY_URL=https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz

# Directory that the ruby managers will be downloaded to
ARG RUBY_MANAGERS_DIR=/tmp/ruby_mangers

# Compiler environment variables that don't need to carry over to the final image
ARG CC=/usr/bin/clang
ARG CXX=/usr/bin/clang++

# Use dkubb's bash strict mode to protect us from bash's many ugliness
COPY build/strict-mode.sh /usr/local/sbin/strict-mode.sh

# Copy over a list of ruby versions to install
COPY build/ruby_matrix /tmp

# Enable strict mode by default
ENV BASH_ENV=/usr/local/sbin/strict-mode.sh

# Write all bundle config to /bundle instead of /app/.bundle
ENV BUNDLE_APP_CONFIG /bundle

RUN apk add --update-cache \
      bash=4.3.42-r3         \
      # provides tools like make
      build-base=0.4-r1      \
      # install clang to reduce the final binary size for our rubies
      clang=3.8.0-r0         \
      # install git so that the bundle can depend on git sources
      git=2.8.3-r0           \
      # required for gems that use ffi
      libffi-dev=3.2.1-r2    \
      # ruby needs access to things like linux/random.h
      linux-headers=4.4.6-r1 \
      # required to compile ruby
      openssl-dev=1.0.2h-r1  \
      # required for ruby-versions to download ruby binaries
      openssl=1.0.2h-r1      \
  # Create ruby managers directory for downloads
  && mkdir "$RUBY_MANAGERS_DIR"

# Download ruby-install
ADD $RUBY_INSTALL_URL "$RUBY_MANAGERS_DIR"

# Download chruby
ADD $CHRUBY_URL "$RUBY_MANAGERS_DIR"

RUN mkdir -p /src/app

WORKDIR /src/app

VOLUME /app

COPY build/docker-exec build/docker-exec

# Copy the bootstrap script used to setup the final image
COPY build/docker-bootstrap.sh /usr/local/sbin

RUN docker-bootstrap.sh

USER ci

ENTRYPOINT ["build/docker-exec"]
