#!/bin/bash

# `make` for ruby-install and chruby don't work within our strict environment
# so we have to unset the BASH_ENV variable before executing their setup.
# The `make` call creates a new shell so doing `set +o [option]` doesn't impact
# the `make install` execution
unset_strict(){
  unset BASH_ENV
}

# Change directories to either chruby's or ruby-install's source directory
# and `make install`
install_manager(){
  local manager_dir="$1"

  (
    unset_strict;
    cd "$manager_dir" || exit 1;
    make install
  )
}

# Install bundler for a given ruby version
install_bundler_for_ruby_version(){
  local ruby_version="$1"

  # chruby unsets variables and uses file globbing
  # execute in a subshell so that environment changes for chruby don't have
  # global effect
  (
    # Only unset the rules that are required to not break chruby
    set +o nounset;
    set +o noglob;
    source /usr/local/share/chruby/chruby.sh
    chruby "$ruby_version"
    gem install bundler
  )
}

# Use ruby-install to install a ruby version
install_ruby_version(){
  local ruby_version="$1"

  # Execute inside of a subshell so that environment changes for ruby-install
  # don't have a global impact
  (
    unset_strict;
    # Skipping doc installation saves space and time during `docker build`
    ruby-install --jobs=8 ruby "$ruby_version" -- --disable-install-doc --disable-install-rdoc --disable-install-capi;
  )

  # Install bundler for the newly installed ruby version
  install_bundler_for_ruby_version "$ruby_version"
}

# Untar all downloaded ruby managers
find "$RUBY_MANAGERS_DIR" -name "*.tar.gz" -exec tar -xzvf {} -C "$RUBY_MANAGERS_DIR" \;

# Load the ruby manager directories into the array `ruby_managers`
mapfile -t ruby_managers < <(find "$RUBY_MANAGERS_DIR" -type d -maxdepth 1 -mindepth 1)

# Load the ruby versions we want to install into the array `ruby_versions`
mapfile -t ruby_versions < /tmp/ruby_matrix

# Call `make install` for all ruby manager directories downloaded
for directory in "${ruby_managers[@]}"; do
  install_manager "$directory"
done

# Remove ruby manager install files now that we are done with them
rm -rf /tmp/ruby_managers

# Install all ruby versions specified in our ruby matrix file
for ruby_version in "${ruby_versions[@]}"; do
  install_ruby_version "$ruby_version"
done

# Create a new unprivileged user named "ci"
adduser -DS -s /bin/bash ci

# Create our separate bundle config directory which ci is allowed to write to
mkdir "$BUNDLE_APP_CONFIG" && chown ci: "$BUNDLE_APP_CONFIG"

# Create a source directory which files are copied to so writes don't impact the host
chown ci: --recursive /src
