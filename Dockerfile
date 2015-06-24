# Ubuntu PostgreSQL.
# Forked from https://github.com/BetterVoice/postgresql-container

FROM ubuntu:14.04.2
MAINTAINER Johann du Toit <johann@impulsecloud.com.au>

# Install.
RUN apt-get update && \
 apt-get install -y \
 daemontools \
 libffi-dev \
 libssl-dev \
 lzop postgresql-9.3 \
 postgresql-client-9.3 \
 postgresql-contrib-9.3 \
 postgresql-9.3-pgpool2 \
 postgresql-9.3-postgis-2.1 \
 pv \
 python \
 python-dev \
 python-pip=1.5.4-1
RUN pip install --upgrade six
RUN pip install Jinja2 wal-e

# Post Install Configuration.
ADD bin/start-postgres /usr/bin/start-postgres
RUN chmod +x /usr/bin/start-postgres
ADD bin/heartbeat.template /usr/share/postgresql/9.3/heartbeat.template
ADD conf/postgresql.conf.template /usr/share/postgresql/9.3/postgresql.conf.template
ADD conf/pg_hba.conf.template /usr/share/postgresql/9.3/pg_hba.conf.template
ADD conf/recovery.conf.template /usr/share/postgresql/9.3/recovery.conf.template

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Open the container up to the world.
EXPOSE 5432/tcp

# Start PostgreSQL.
CMD start-postgres
