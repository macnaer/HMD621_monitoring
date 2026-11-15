# Cisco OIDs for phase 1

Status: confirmed by an SNMP walk on the ISR4431 at `10.7.0.101` on 2026-11-15. Numeric OIDs, no MIB files required.

| Purpose | MIB object | OID | Notes |
|---|---|---|---|
| System uptime | SNMPv2-MIB sysUpTime | 1.3.6.1.2.1.1.3.0 | Scalar, index 0 |
| Interface description | IF-MIB ifDescr | 1.3.6.1.2.1.2.2.1.2 | Table, index is ifIndex |
| Interface type | IF-MIB ifType | 1.3.6.1.2.1.2.2.1.3 | 6 means ethernetCsmacd, 135 means l2vlan (dot1q subinterfaces), 1 means other (Service-Engine, Null0) |
| Interface admin status | IF-MIB ifAdminStatus | 1.3.6.1.2.1.2.2.1.7 | 1 means up, 2 means down. Indexes 3-6 and 8 are admin down (expected) |
| Interface operational status | IF-MIB ifOperStatus | 1.3.6.1.2.1.2.2.1.8 | 1 means up, 2 means down |
| CPU 5-minute average | CISCO-PROCESS-MIB cpmCPUTotal5minRev | 1.3.6.1.4.1.9.9.109.1.1.1.1.8.7 | Scalar-ish: single entry, index 7 confirmed |
| Memory pool name | CISCO-MEMORY-POOL-MIB ciscoMemoryPoolName | 1.3.6.1.4.1.9.9.48.1.1.1.2 | Table |
| Memory pool used | ciscoMemoryPoolUsed | 1.3.6.1.4.1.9.9.48.1.1.1.5 | Table |
| Memory pool free | ciscoMemoryPoolFree | 1.3.6.1.4.1.9.9.48.1.1.1.6 | Table |

## Confirmed interface index map

| ifIndex | ifDescr | ifType | ifAdminStatus | ifOperStatus | Monitored |
|---|---|---|---|---|---|
| 1 | GigabitEthernet0/0/0 | 6 | up | up | yes |
| 2 | GigabitEthernet0/0/1 | 6 | up | up | yes |
| 3 | GigabitEthernet0/0/2 | 6 | down | down | no (admin down) |
| 4 | GigabitEthernet0/0/3 | 6 | down | down | no (admin down) |
| 5 | GigabitEthernet0/1/0 | 6 | down | down | no (admin down) |
| 6 | GigabitEthernet0/1/1 | 6 | down | down | no (admin down) |
| 7 | Service-Engine0/4/0 | 1 | up | up | yes |
| 8 | GigabitEthernet0 | 6 | down | down | no (admin down) |
| 9 | Null0 | 1 | up | up | no (null interface) |
| 10-54, 57 | GigabitEthernet0/0/1.x | 135 | up | up | no (dot1q subinterfaces) |

## Not supported on this device

| Purpose | MIB object | Result |
|---|---|---|
| Temperature | CISCO-ENVMON-MIB ciscoEnvMonTemperatureStatusDescr (1.3.6.1.4.1.9.9.13.1.3.1.2) | Walk returns `No Such Object available on this agent at this OID`. Do not add a temperature check. |
