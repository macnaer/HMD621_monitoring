# ADR 0001: Monitoring Stack for Phase 1

- Status: Accepted
- Date: 2026-11-08

## Context

The project monitors Cisco switches and routers, Hikvision IP cameras, and Linux servers. Phase 1 covers a single device: Cisco ISR4431/K9 running IOS-XE 17.9.5a at 10.7.0.101. The monitoring host is Ubuntu Server 26.04 LTS at 10.7.99.103.

## Decision

- Monitoring core: Nagios Core 4.x, built from the official source in a Docker image based on `ubuntu:24.04`.
- Web UI: Thruk in a separate container, served over HTTPS and limited to the admin network.
- Configuration: plain-text Nagios objects stored in this repository and mounted into the container. Syntax is checked with `nagios -v` before reload. Changes go through pull requests.
- Device access: SNMPv2c with a read-only community, restricted by an ACL to 10.7.99.103. Community strings are never stored in this repository.
- Phase 1 checks: ICMP reachability and `check_snmp` for uptime, CPU (5-minute average), memory, status of all physical interfaces, and temperature where exposed.
- Thresholds: CPU warning 80%, critical 90%. Memory warning 85%, critical 95%. Check interval 5 minutes.
- Notifications: Telegram group, deferred to a later phase.
- Deferred: LibreNMS, SNMP traps, Hikvision cameras, Linux servers.

## Consequences

- SNMPv2c sends community strings in clear text. Mitigated by a read-only community, an ACL, and a dedicated community string. Migration to SNMPv3 is a possible future change.
- The `ubuntu:24.04` base image is used because Nagios Core documents support up to 24.04, while the host runs 26.04.
- Docker traffic to the router is source-NATed to 10.7.99.103, so the router ACL must permit that address.
- Some checks (for example, memory percentage) need a small wrapper script because `check_snmp` does not calculate percentages.

## Open items

- Confirm the exact interface list from an SNMP walk on the router.
- Choose the approach for the percentage-based memory check.
