# Ubuntu PostgreSQL.
# Forked from https://github.com/BetterVoice/postgresql-container

FROM impulsecloud/ic-ubuntu:latest
MAINTAINER Johann du Toit <johann@winkreports.com>

# Install.
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
 wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && \
 apt-get update && \
 apt-get install -y \
 daemontools \
 libffi-dev \
 libssl-dev \
 lzop postgresql-9.6 \
 postgresql-client-9.6 \
 postgresql-contrib-9.6 \
 pv \
 sudo && \
 pip3 install --upgrade six && \
 pip3 install Jinja2 wal-e boto && \
 apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Post Install Configuration.
ADD bin/start-postgres /usr/bin/start-postgres
RUN chmod +x /usr/bin/start-postgres
ADD bin/docker-wait /usr/bin/docker-wait
RUN chmod +x /usr/bin/docker-wait
ADD bin/heartbeat.template /usr/share/postgresql/9.6/heartbeat.template
ADD bin/backupcron.template /usr/share/postgresql/9.6/backupcron.template
ADD conf/postgresql.conf.template /usr/share/postgresql/9.6/postgresql.conf.template
ADD conf/pg_hba.conf.template /usr/share/postgresql/9.6/pg_hba.conf.template
ADD conf/recovery.conf.template /usr/share/postgresql/9.6/recovery.conf.template

# work around for AUFS bug
# as per https://github.com/docker/docker/issues/783#issuecomment-56013588
RUN mkdir -p /var/lib/postgresql/ssl ;\
    chown postgres:postgres /var/lib/postgresql/ssl ;\
    cp /etc/ssl/certs/ssl-cert-snakeoil.pem /var/lib/postgresql/ssl/ ;\
    cp /etc/ssl/private/ssl-cert-snakeoil.key /var/lib/postgresql/ssl/ ;\
    chown -R postgres:postgres /var/lib/postgresql/ssl/ssl-cert-snakeoil.* ;\
    chmod 600 /var/lib/postgresql/ssl/*


# Open the container up to the world.
EXPOSE 5432/tcp

# Allow configuration mount points
VOLUME /etc/postgresql /var/lib/postgresql

# Start PostgreSQL.
CMD /usr/bin/start-postgres
