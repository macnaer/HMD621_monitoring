---
name: nagios-operations
description: Use when operating the Nagios Core Docker deployment for HMD621, including building the image, validating configuration with nagios -v, restarting, reading container logs, checking the web interface, changing the admin password, and troubleshooting startup problems. Covers the runbook procedures on the monitoring host.
---

# Nagios operations

The operator runs these commands on the server. The agent has no server access and asks for the output.

## Preconditions

- Run commands from `~/HMD621_monitoring/docker`, where `docker-compose.yml` lives.
- `docker/.env` exists with permissions 600 and contains the variables from `.env.example`.
- Update the repository with `git pull` before building.

## Procedures

| Task | Command |
|---|---|
| Build and start | `docker compose up -d --build` |
| Status | `docker compose ps` |
| Logs | `docker compose logs --tail=100 nagios` |
| Validate configuration | `docker compose exec nagios /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg` |
| Restart after a valid change | `docker compose restart nagios` |
| Change the admin password | Edit `NAGIOS_ADMIN_PASSWORD` in `.env`, then run `docker compose up -d` |
| Regenerate the certificate | `rm -f certs/nagios.crt certs/nagios.key`, then `docker compose restart nagios` |

## Rules

- Validate with `nagios -v` before every restart. Do not restart after a failed validation.
- The container name is `hmd621-nagios`. Do not stop, remove, or change containers that this project does not own.
- Never print `.env` values or the SNMP community in the chat. To check that a variable is set, use a command such as `grep -c '^SNMP_RO_COMMUNITY=' .env`.

## Troubleshooting

| Symptom | Likely cause | Check |
|---|---|---|
| Name conflict on start | Another container uses the same name | `sudo docker ps` |
| Entrypoint exits with "must be set" | Missing variable in `.env` | Compare with `.env.example` |
| Build fails in `configure` | Missing build dependency | The log line before the error |
| Web page shows PHP source | PHP is not installed in the image | Rebuild after the PHP change |
| Checks return UNKNOWN | SNMP blocked or wrong community | Runbook section 6a and the router ACL |

## Reporting

When asking for help, request the last 100 lines of `docker compose logs` and the output of the failing command. Remove secrets before sharing.
