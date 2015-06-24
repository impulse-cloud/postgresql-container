# Ubuntu PostgreSQL.
# Forked from https://github.com/BetterVoice/postgresql-container

FROM impulsecloud/ic-ubuntu:latest
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
 pv && \
 pip install --upgrade six && \
 pip install Jinja2 wal-e && \
 apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Post Install Configuration.
ADD bin/start-postgres /usr/bin/start-postgres
RUN chmod +x /usr/bin/start-postgres
ADD bin/heartbeat.template /usr/share/postgresql/9.3/heartbeat.template
ADD conf/postgresql.conf.template /usr/share/postgresql/9.3/postgresql.conf.template
ADD conf/pg_hba.conf.template /usr/share/postgresql/9.3/pg_hba.conf.template
ADD conf/recovery.conf.template /usr/share/postgresql/9.3/recovery.conf.template

# work around for AUFS bug
# as per https://github.com/docker/docker/issues/783#issuecomment-56013588
RUN mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -rf /etc/ssl/private/*; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private; chown postgres /etc/ssl/private/ssl-cert-snakeoil.key; chown postgres /etc/ssl/certs/ssl-cert-snakeoil.pem

# Open the container up to the world.
EXPOSE 5432/tcp

# Start PostgreSQL.
CMD start-postgres
