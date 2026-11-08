# HMD621 Monitoring

Monitoring system for network equipment and servers:

- Cisco switches and routers (SNMP)
- Hikvision IP cameras (planned)
- Linux servers (planned)

## Status

Phase 1 covers one device: a Cisco ISR4431/K9 running IOS-XE 17.9.5a at `10.7.0.101`. Nagios Core runs in Docker on Ubuntu Server 26.04 at `10.7.99.103`.

| Component | Status |
|---|---|
| Nagios Core 4.5.14 in Docker | Implemented and running |
| Nagios web interface (CGI and PHP) | Implemented, PHP fix pending verification |
| ICMP, uptime, and memory checks | Implemented, SNMP results pending |
| CPU, interface, and temperature checks | Planned, needs SNMP walk |
| Thruk web interface | Deferred, depends on Livestatus build |
| Telegram notifications | Deferred |
| LibreNMS and SNMP traps | Deferred |
| Hikvision cameras and Linux servers | Later phases |

## Repository layout

```
AGENTS.md               Rules for AI agents working in this repository
.opencode/skills/       Project agent skills
docker/
  docker-compose.yml    Nagios service definition
  .env.example          Template for the server-side .env (never commit .env)
  nagios/               Dockerfile, entrypoint, supervisord, check plugins
docs/
  adr/                  Architecture decision records
  runbooks/             Server setup and operations
nagios/
  conf.d/               Nagios object configuration, mounted into the container
.github/                Pull request template
```

## Getting started

Server setup and operations: [docs/runbooks/server-setup.md](docs/runbooks/server-setup.md).

Phase 1 decisions: [docs/adr/0001-monitoring-stack.md](docs/adr/0001-monitoring-stack.md).

## Contributing

- `master` is the default branch. Do not commit or push to it directly.
- Make changes on a branch with the `feature/`, `fix/`, or `docs/` prefix and open a pull request.
- Fill in the pull request template.
- A maintainer merges the pull request.

## Security

- Never commit `.env` files, SNMP community strings, API tokens, chat IDs, passwords, or private keys.
- Keep secrets on the server in `docker/.env`, which Git ignores.
- Use placeholders such as `<SNMP_RO_COMMUNITY>` in examples.
