# Ubuntu PostgreSQL.
# Forked from https://github.com/BetterVoice/postgresql-container

FROM impulsecloud/ic-ubuntu:latest
MAINTAINER Johann du Toit <johann@winkreports.com>

# Install.
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
 echo 'deb-src http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' >> /etc/apt/sources.list.d/pgdg.list && \
 wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && \
 apt-get update && \
 apt-get install -y \
 build-essential \
 daemontools \
 devscripts \
 iputils-ping \
 libffi-dev \
 libssl-dev \
 lzop postgresql-12 \
 postgresql-client-12 \
 postgresql-contrib-12 \
 python3-dev \
 python3-pip \
 python3-setuptools \
 pv \
 sudo

RUN cd /tmp && \
 apt-get build-dep -y postgresql-12 && \
 wget https://ftp.postgresql.org/pub/snapshot/12/postgresql-12-snapshot.tar.gz && \
 tar -zxvf postgresql-12-snapshot.tar.gz && \
 cd postgresql-12.1 && \
 ./configure --build=x86_64-linux-gnu --prefix=/usr --includedir=\${prefix}/include --mandir=\${prefix}/share/man --infodir=\${prefix}/share/info --sysconfdir=/etc --localstatedir=/var --disable-silent-rules --libdir=\${prefix}/lib/x86_64-linux-gnu --libexecdir=\${prefix}/lib/x86_64-linux-gnu --disable-maintainer-mode --disable-dependency-tracking --with-icu --with-tcl --with-perl --with-python --with-pam --with-openssl --with-libxml --with-libxslt PYTHON=/usr/bin/python3 --mandir=/usr/share/postgresql/12/man --docdir=/usr/share/doc/postgresql-doc-12 --sysconfdir=/etc/postgresql-common --datarootdir=/usr/share/ --datadir=/usr/share/postgresql/12 --bindir=/usr/lib/postgresql/12/bin --libdir=/usr/lib/x86_64-linux-gnu/ --libexecdir=/usr/lib/postgresql/ --includedir=/usr/include/postgresql/ "--with-extra-version= (Ubuntu 12.1-1.pgdg16.04+1)" --enable-nls --enable-integer-datetimes --enable-thread-safety --enable-tap-tests --enable-debug --enable-dtrace --disable-rpath --with-uuid=e2fs --with-gnu-ld --with-pgport=5432 --with-system-tzdata=/usr/share/zoneinfo --with-llvm LLVM_CONFIG=/usr/bin/llvm-config-6.0 CLANG=/usr/bin/clang-6.0 --with-systemd --with-selinux "MKDIR_P=/bin/mkdir -p" TAR=/bin/tar "CFLAGS=-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -fPIC -pie -fno-omit-frame-pointer" "LDFLAGS=-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,-z,now" --with-gssapi --with-ldap --with-includes=/usr/include/mit-krb5 --with-libs=/usr/lib/mit-krb5 --with-libs=/usr/lib/x86_64-linux-gnu/mit-krb5 && \
 make && \
 make install

RUN pip3 install --upgrade six && \
 pip3 install Jinja2 boto wal-e && \
 apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the locale
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Post Install Configuration.
ADD bin/start-postgres /usr/bin/start-postgres
RUN chmod +x /usr/bin/start-postgres
ADD bin/docker-wait /usr/bin/docker-wait
RUN chmod +x /usr/bin/docker-wait
ADD bin/heartbeat.template /usr/share/postgresql/12/heartbeat.template
ADD bin/backupcron.template /usr/share/postgresql/12/backupcron.template
ADD conf/postgresql.conf.template /usr/share/postgresql/12/postgresql.conf.template
ADD conf/pg_hba.conf.template /usr/share/postgresql/12/pg_hba.conf.template

# work around for AUFS bug
# as per https://github.com/docker/docker/issues/783#issuecomment-56013588
RUN mkdir -p /var/lib/postgresql/ssl ;\
    chown postgres:postgres /var/lib/postgresql/ssl ;\
    cp /etc/ssl/certs/ssl-cert-snakeoil.pem /var/lib/postgresql/ssl/ ;\
    cp /etc/ssl/private/ssl-cert-snakeoil.key /var/lib/postgresql/ssl/ ;\
    chown -R postgres:postgres /var/lib/postgresql/ssl/ssl-cert-snakeoil.* ;\
    chmod 600 /var/lib/postgresql/ssl/* ;\
    chmod 700 /var/lib/postgresql/ssl


# Open the container up to the world.
EXPOSE 5432/tcp

# Allow configuration mount points
VOLUME /etc/postgresql /var/lib/postgresql

# Start PostgreSQL.
CMD /usr/bin/start-postgres
