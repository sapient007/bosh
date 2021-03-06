#!/usr/bin/env bash

set -e

# Install BOSH dependencies
echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list && wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && apt-get update
apt-get install -y \
	mysql-client \
	libmariadbclient-dev \
	postgresql-client-9.4 \
	libpq-dev \
	sqlite3 \
	libsqlite3-dev \
	mercurial \
	lsof \
	unzip \
	realpath
apt-get clean

# Install bosh-cli
wget https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-0.0.147-linux-amd64 -O /bin/bosh-cli
echo "533342d7663c3e5dc731769e157608c74dd9eccb  /bin/bosh-cli" | sha1sum -c -
chmod +x /bin/bosh-cli

# Install BOSH CLI
gem install bosh_cli --no-document
