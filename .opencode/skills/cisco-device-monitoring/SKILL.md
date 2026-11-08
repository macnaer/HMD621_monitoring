---
name: cisco-device-monitoring
description: Use when adding or changing monitoring of Cisco IOS-XE routers or switches, including SNMP setup on the device, ACLs, OID verification with snmpwalk, Nagios check_snmp commands, and thresholds. Covers the Cisco ISR4431/K9 in phase 1.
---

# Cisco device monitoring

## Phase 1 device

- Model: Cisco ISR4431/K9, IOS-XE 17.9.5a, management address `10.7.0.101`.
- Monitoring host: `10.7.99.103`. It is the only SNMP source allowed by the ACL.
- Access: SNMPv2c with a read-only community. The community is stored only in `docker/.env` on the server as `SNMP_RO_COMMUNITY`. Never write it into the repository.

## Device configuration (placeholders only)

```
ip access-list standard SNMP-MGMT
 permit 10.7.99.103
!
snmp-server community <SNMP_RO_COMMUNITY> RO SNMP-MGMT
```

Do not configure SNMP traps unless the user approves the traps phase.

## Verify OIDs before use

1. Ask the user to run an SNMP walk from the Nagios container, using numeric OIDs so no MIB files are needed. The community is read from `.env` and is never printed.
2. Compare the result with `references/oids.md`. If an OID or table index differs, update the check and mention the change in the pull request.
3. Never invent OIDs or device capabilities.

## Check conventions

- Use `check_snmp` from the Nagios plugins with `-P 2c`, `-C $USER5$`, and an explicit `-o` OID.
- Thresholds from the ADR: CPU warning 80%, critical 90%. Memory 85% and 95%. Check interval 5 minutes.
- Percent-based checks use a wrapper script. Memory uses `check_cisco_mem.sh`.

## Phase 1 checks

| Check | Method | Status |
|---|---|---|
| ICMP reachability | host check `check-host-alive` | Implemented |
| Uptime | `check_snmp_uptime` | Implemented, server verification pending |
| Memory | `check_cisco_mem.sh` | Implemented, server verification pending |
| CPU (5 minutes) | `cpmCPUTotal5minRev` | Planned, needs walk for the index |
| Interfaces | `ifOperStatus` for physical interfaces | Planned, needs walk for the list |
| Temperature | CISCO-ENVMON-MIB | Planned, only if the device reports it |

## Verification

- `nagios -v` shows `Total Errors: 0`.
- The SNMP checks in runbook section 6a return OK.
- The web interface shows the host and its services.
