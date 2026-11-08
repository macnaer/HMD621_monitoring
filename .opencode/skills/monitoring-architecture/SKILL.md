---
name: monitoring-architecture
description: Use when planning or changing the monitoring architecture or technology stack, comparing tools (Nagios, Thruk, Icinga, Naemon, Checkmk, LibreNMS, Grafana, Telegram alerting), or writing architecture decision records (ADR). Presents options with trade-offs and requires approval before the stack changes.
---

# Monitoring architecture

## Principles

- The phase 1 stack is defined in `docs/adr/0001-monitoring-stack.md`. Treat it as the source of truth.
- Changing the stack requires a new ADR and the user's approval. Do not change the stack in code first.
- When a choice is needed, present 2 to 3 options. For each option, list benefits, risks, license, operational cost, and fit with the existing environment. Recommend one and wait for approval.
- State assumptions. Ask questions when requirements are missing: device count, polling intervals, retention, alert channels, hosting, budget.

## Comparison checklist

- Protocol coverage: SNMP versions, telemetry, syslog, traps, HTTP APIs.
- Scale: number of devices, polling rate, storage for history.
- Operations: Docker support, configuration as code in Git, backups, upgrades.
- Licensing and support: open source license, commercial editions, support options.
- Team fit: skills and tools already running on the server.

## ADR process

1. Copy `references/adr-template.md` to `docs/adr/NNNN-short-title.md`, using the next free number.
2. Fill in Context, Options, Decision, Consequences, and Open items. Keep the status `Proposed` until the user approves.
3. Open a pull request. Change the status to `Accepted` in the same or a follow-up pull request, as the user decides.

## Verification

Check product versions and capabilities against official sources before recommending them. If a source is unavailable, say so.
