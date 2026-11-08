---
name: linux-server-monitoring
description: Use when planning or implementing monitoring of Linux servers, including choosing agent-based or agentless collection, SSH key access, least-privilege monitoring accounts, and Nagios checks for Linux hosts. Planned for a later phase of the project.
---

# Linux server monitoring

Status: planned for a later phase. Do not implement checks until the user approves the phase.

## Options

| Option | Benefits | Risks |
|---|---|---|
| Agentless over SSH (Nagios `check_by_ssh`) | No software on target hosts | SSH access and key management |
| Metrics exporter (for example, node_exporter) | Rich metrics in a standard format | One more service to maintain |
| Nagios agent (NRPE or NCPA) | Native Nagios checks | Agent configuration and updates |

Present these options with trade-offs and wait for the user's choice. See the `monitoring-architecture` skill.

## Principles

- Use key-based SSH authentication. Disable password logins for monitoring accounts.
- Create a dedicated monitoring account with the least privileges that each check needs.
- Restrict the monitoring account and any agent port to the monitoring host.
- Never store private keys or passwords in the repository.
