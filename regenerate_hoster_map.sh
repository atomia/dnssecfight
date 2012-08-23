#!/bin/sh
cat zones_with_ds.net.txt | cut -d " " -f 3 | sed 's/\([^.]\)$/\1.NET./' | sort -u | while read ns; do echo -n "$ns $(date +%s) "; echo -n "$(dig +noall +answer +authority soa "$ns" @"$ns" 2>&1) "; date +%s; done > net_ns_soa.txt

cat net_ns_soa.txt | grep -i "[[:space:]]IN[[:space:]]*SOA[[:space:]]" | sed 's/^\([^[:space:]]*\).*[[:space:]]IN[[:space:]]*SOA[[:space:]]*[^[:space:]]*[[:space:]]*\([^[:space:]]*\).*$/\1 \2/' | tr "a-z" "A-Z" | sed 's/\([^.]\)$/\1./' | while read ns hoster; do echo "$ns $(echo "$hoster" | cut -d . -f 2-)"; done > hoster_map
