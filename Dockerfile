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
ADD bin/docker-wait /usr/bin/docker-wait
RUN chmod +x /usr/bin/docker-wait
ADD bin/heartbeat.template /usr/share/postgresql/9.3/heartbeat.template
ADD bin/backupcron.template /usr/share/postgresql/9.3/backupcron.template
ADD conf/postgresql.conf.template /usr/share/postgresql/9.3/postgresql.conf.template
ADD conf/pg_hba.conf.template /usr/share/postgresql/9.3/pg_hba.conf.template
ADD conf/recovery.conf.template /usr/share/postgresql/9.3/recovery.conf.template

# work around for AUFS bug
# as per https://github.com/docker/docker/issues/783#issuecomment-56013588
RUN mkdir -p /var/lib/postgresql/ssl ;\
    chown postgres:postgres /var/lib/postgresql/ssl ;\
    cp /etc/ssl/certs/ssl-cert-snakeoil.pem /var/lib/postgresql/ssl/ ;\
    cp /etc/ssl/private/ssl-cert-snakeoil.key /var/lib/postgresql/ssl/ ;\
    chown -R postgres:postgres /var/lib/postgresql/ssl/ssl-cert-snakeoil.*


# Open the container up to the world.
EXPOSE 5432/tcp

# Allow configuration mount points
VOLUME /etc/postgresql /var/lib/postgresql

# Start PostgreSQL.
CMD start-postgres
