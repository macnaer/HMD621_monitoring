# Cisco OIDs for phase 1

Status: candidates based on the MIB object definitions. Confirm each OID and table index with an SNMP walk on the device before using it in a check.

| Purpose | MIB object | Base OID | Notes |
|---|---|---|---|
| System uptime | SNMPv2-MIB sysUpTime | 1.3.6.1.2.1.1.3.0 | Scalar, index 0 |
| Interface description | IF-MIB ifDescr | 1.3.6.1.2.1.2.2.1.2 | Table, index is ifIndex |
| Interface type | IF-MIB ifType | 1.3.6.1.2.1.2.2.1.3 | 6 means ethernetCsmacd (physical) |
| Interface operational status | IF-MIB ifOperStatus | 1.3.6.1.2.1.2.2.1.8 | 1 means up, 2 means down |
| CPU 5-minute average | CISCO-PROCESS-MIB cpmCPUTotal5minRev | 1.3.6.1.4.1.9.9.109.1.1.1.1.8 | Table, index from walk |
| Memory pool name | CISCO-MEMORY-POOL-MIB ciscoMemoryPoolName | 1.3.6.1.4.1.9.9.48.1.1.1.2 | Table |
| Memory pool used | ciscoMemoryPoolUsed | 1.3.6.1.4.1.9.9.48.1.1.1.5 | Table |
| Memory pool free | ciscoMemoryPoolFree | 1.3.6.1.4.1.9.9.48.1.1.1.6 | Table |
| Temperature description | CISCO-ENVMON-MIB ciscoEnvMonTemperatureStatusDescr | 1.3.6.1.4.1.9.9.13.1.3.1.2 | Table, may be empty |
| Temperature value | ciscoEnvMonTemperatureStatusValue | 1.3.6.1.4.1.9.9.13.1.3.1.3 | Table, may be empty |
