FROM ubuntu:24.04

ARG NAGIOS_VERSION=4.5.14
ARG NAGIOS_CORE_SHA256=dce59f306577789c56d2748471d4c3856ecba8572d6b0811cf79f9de2f9afabb
ARG NAGIOS_PLUGINS_VERSION=2.5
ARG NAGIOS_PLUGINS_SHA256=44d1510b5e17055fd9aa4a1d9662a234fc5d5c1b96548852c8e78701584b2684

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      apache2 apache2-utils build-essential ca-certificates libcap2-bin libgd-dev \
      libssl-dev openssl snmp supervisor unzip wget \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/build && cd /tmp/build \
 && wget -q "https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-${NAGIOS_VERSION}/nagios-${NAGIOS_VERSION}.tar.gz" \
 && echo "${NAGIOS_CORE_SHA256}  nagios-${NAGIOS_VERSION}.tar.gz" | sha256sum -c - \
 && tar xzf "nagios-${NAGIOS_VERSION}.tar.gz" \
 && cd "nagios-${NAGIOS_VERSION}" \
 && ./configure --with-httpd-conf=/etc/apache2/sites-enabled \
 && make all \
 && make install-groups-users \
 && usermod -a -G nagios www-data \
 && make install \
 && make install-commandmode \
 && make install-config \
 && make install-webconf

RUN cd /tmp/build \
 && wget -q "https://github.com/nagios-plugins/nagios-plugins/releases/download/release-${NAGIOS_PLUGINS_VERSION}/nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz" \
 && echo "${NAGIOS_PLUGINS_SHA256}  nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz" | sha256sum -c - \
 && tar xzf "nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz" \
 && cd "nagios-plugins-${NAGIOS_PLUGINS_VERSION}" \
 && ./configure --prefix=/usr/local/nagios --with-nagios-user=nagios --with-nagios-group=nagios \
 && make \
 && make install \
 && setcap cap_net_raw+ep /usr/local/nagios/libexec/check_icmp \
 && rm -rf /tmp/build

RUN mkdir -p /usr/local/nagios/etc/conf.d /certs \
 && echo "cfg_dir=/usr/local/nagios/etc/conf.d" >> /usr/local/nagios/etc/nagios.cfg \
 && a2dissite 000-default \
 && a2enmod ssl cgi rewrite \
 && a2ensite default-ssl \
 && echo "ServerName localhost" > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername \
 && sed -i 's#/etc/ssl/certs/ssl-cert-snakeoil.pem#/certs/nagios.crt#; s#/etc/ssl/private/ssl-cert-snakeoil.key#/certs/nagios.key#' /etc/apache2/sites-available/default-ssl.conf

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
COPY plugins/check_cisco_mem.sh /usr/local/nagios/libexec/check_cisco_mem.sh
RUN chmod 755 /usr/local/nagios/libexec/check_cisco_mem.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
