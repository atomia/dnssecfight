#!/bin/sh

basedir="/some/dir/where/daily/zones/are/stored"

if [ -z "$1" ] || [ ! -d "$basedir/$1" ]; then
        echo "usage: $0 20110921"
        exit 1
fi

day="$1"
dir="$basedir/$day"

for tld in net com; do
        if [ -f "$dir/$tld".zone.gz.md5 ]; then
                zcat "$dir/$tld".zone.gz | fgrep " DS " | awk '$3 == "DS" { print }' > "$dir/${tld}_ds_records.txt"
                zcat "$dir/$tld".zone.gz | awk -vds_file="$dir/${tld}_ds_records.txt" '
                        BEGIN { while (getline < ds_file) { has_ds[$1] = 1 } } $1 in has_ds && $2 == "NS" { print }
                ' > "$dir/zones_with_ds.$day.$tld.txt"
                rsync --delay-updates "$dir/zones_with_ds.$day.$tld.txt" root@some.host.com:/home/someuser/dnssec_fight/pending
        fi
done
