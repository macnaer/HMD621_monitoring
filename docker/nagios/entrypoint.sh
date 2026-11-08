#!/bin/sh
set -eu

: "${NAGIOS_ADMIN_USER:?NAGIOS_ADMIN_USER must be set in docker/.env}"
: "${NAGIOS_ADMIN_PASSWORD:?NAGIOS_ADMIN_PASSWORD must be set in docker/.env}"
: "${CERT_IP:?CERT_IP must be set in docker/.env}"
: "${SNMP_RO_COMMUNITY:?SNMP_RO_COMMUNITY must be set in docker/.env}"

HTPASSWD_FILE=/usr/local/nagios/etc/htpasswd.users
htpasswd -B -b -c "$HTPASSWD_FILE" "$NAGIOS_ADMIN_USER" "$NAGIOS_ADMIN_PASSWORD"
chown root:nagios "$HTPASSWD_FILE"
chmod 640 "$HTPASSWD_FILE"

RESOURCE_FILE=/usr/local/nagios/etc/resource.cfg
printf '$USER1$=/usr/local/nagios/libexec\n$USER5$=%s\n' "$SNMP_RO_COMMUNITY" > "$RESOURCE_FILE"
chown root:nagios "$RESOURCE_FILE"
chmod 640 "$RESOURCE_FILE"

if [ ! -f /certs/nagios.crt ] || [ ! -f /certs/nagios.key ]; then
  echo "Generating self-signed certificate for ${CERT_IP}"
  openssl req -x509 -nodes -newkey rsa:2048 -days 825 \
    -keyout /certs/nagios.key -out /certs/nagios.crt \
    -subj "/CN=${CERT_IP}" -addext "subjectAltName=IP:${CERT_IP}"
  chmod 600 /certs/nagios.key
fi

/usr/sbin/apache2ctl configtest
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

exec /usr/bin/supervisord -c /etc/supervisord.conf
