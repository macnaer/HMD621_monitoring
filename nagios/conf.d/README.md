# Nagios object configuration

Every `*.cfg` file in this directory is loaded by Nagios through `cfg_dir`.
The directory is mounted read-only into the Nagios container at
`/usr/local/nagios/etc/conf.d`.

Validate changes before restarting Nagios:

    docker compose exec nagios /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
