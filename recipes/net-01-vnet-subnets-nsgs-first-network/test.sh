#!/usr/bin/env bash
# NET-01: tests the NSG rules from inside the VNet. Runs a small probe on vm-web and vm-app with Run Command
# (no SSH, no public IP) and prints one line per connection: expected, actual, OK or NO.
set -euo pipefail
rg="rg-recipe-net-01"

# Same probe as test.ps1: open a TCP connection with a 3-second timeout.
# shellcheck disable=SC2016  # the probe is sent to the VM as text and expanded there
probe='probe() {  # from to ip port expected
  if timeout 3 bash -c "</dev/tcp/$3/$4" 2>/dev/null; then got=allowed; else got=blocked; fi
  if [ "$got" = "$5" ]; then ok=OK; else ok=NO; fi
  printf "%-3s %-4s -> %-4s %-15s expected %-7s got %s\n" "$ok" "$1" "$2" "$3:$4" "$5" "$got"
}'

run() {  # vm script
  az vm run-command invoke -g "$rg" -n "$1" --command-id RunShellScript --scripts "$2" \
    --query "value[0].message" -o tsv | sed -n '/\[stdout\]/,/\[stderr\]/p' | sed '1d;$d' | sed '/^$/d'
}

run vm-web "$probe
probe web app  10.10.2.4 8080 allowed
probe web app  10.10.2.4 22   blocked
probe web data 10.10.3.4 5432 blocked"

run vm-app "$probe
probe app data 10.10.3.4 5432 allowed
probe app web  10.10.1.4 22   blocked"
