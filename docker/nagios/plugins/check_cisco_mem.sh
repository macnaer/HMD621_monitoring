#!/bin/sh
# Checks memory pool utilization of a Cisco device via CISCO-MEMORY-POOL-MIB.
# Usage: check_cisco_mem.sh <host> <community> <warning_pct> <critical_pct>
# Reports the pool with the highest utilization.
# Exit codes: 0 OK, 1 WARNING, 2 CRITICAL, 3 UNKNOWN.

set -eu

if [ "$#" -ne 4 ]; then
  echo "UNKNOWN - usage: $0 <host> <community> <warning_pct> <critical_pct>"
  exit 3
fi

HOST="$1"
COMMUNITY="$2"
WARN="$3"
CRIT="$4"

# ciscoMemoryPoolTable (1.3.6.1.4.1.9.9.48.1.1.1): column 5 = Used, column 6 = Free
if ! TABLE=$(snmpwalk -v2c -c "$COMMUNITY" -On -Oq "$HOST" 1.3.6.1.4.1.9.9.48.1.1.1 2>/dev/null); then
  echo "UNKNOWN - SNMP query to $HOST failed"
  exit 3
fi

printf '%s\n' "$TABLE" | awk -v warn="$WARN" -v crit="$CRIT" '
  {
    n = split($1, p, ".")
    idx = p[n]; col = p[n - 1]
    if (col == 5) used[idx] = $2
    if (col == 6) free[idx] = $2
  }
  END {
    worst = -1
    for (i in used) {
      if (!(i in free)) continue
      total = used[i] + free[i]
      if (total <= 0) continue
      pct = used[i] * 100 / total
      if (pct > worst) worst = pct
    }
    if (worst < 0) {
      print "UNKNOWN - no memory pools found"
      exit 3
    }
    worst_int = int(worst)
    perf = sprintf("mem_used_pct=%d%%;%s;%s;0;100", worst_int, warn, crit)
    if (worst >= crit) { print "CRITICAL - memory utilization " worst_int "% | " perf; exit 2 }
    if (worst >= warn) { print "WARNING - memory utilization " worst_int "% | " perf; exit 1 }
    print "OK - memory utilization " worst_int "% | " perf
    exit 0
  }'
