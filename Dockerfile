# Ubuntu PostgreSQL.
# Forked from https://github.com/BetterVoice/postgresql-container

FROM impulsecloud/ic-ubuntu:latest
MAINTAINER Johann du Toit <johann@impulsecloud.com.au>

# Set up posgres apt repository
ADD bin/apt.postgresql.org.sh /usr/bin/apt.postgresql.org.sh
RUN chmod +x /usr/bin/apt.postgresql.org.sh

# Install.
RUN /usr/bin/apt.postgresql.org.sh && \
 apt-get update && \
 apt-get install -y \
 daemontools \
 libffi-dev \
 libssl-dev \
 lzop postgresql-9.5 \
 postgresql-client-9.5 \
 postgresql-contrib-9.5 \
 pv \
 sudo && \
 pip install --upgrade six && \
 pip install Jinja2 wal-e && \
 apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Post Install Configuration.
ADD bin/start-postgres /usr/bin/start-postgres
RUN chmod +x /usr/bin/start-postgres
ADD bin/docker-wait /usr/bin/docker-wait
RUN chmod +x /usr/bin/docker-wait
ADD bin/heartbeat.template /usr/share/postgresql/9.5/heartbeat.template
ADD bin/backupcron.template /usr/share/postgresql/9.5/backupcron.template
ADD conf/postgresql.conf.template /usr/share/postgresql/9.5/postgresql.conf.template
ADD conf/pg_hba.conf.template /usr/share/postgresql/9.5/pg_hba.conf.template
ADD conf/recovery.conf.template /usr/share/postgresql/9.5/recovery.conf.template

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
