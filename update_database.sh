#!/bin/sh

cd `dirname "$0"`

mysql="mysql --defaults-file=/etc/mysql/debian.cnf"
$mysql < ddl.sql
mysql="$mysql dnssecfight"


tlds="com net"

ls pending | cut -d . -f 2 | sort -u | grep -E '^[0-9]{8}$' | while read date; do
	tld_count=`echo "$tlds" | tr " " "\n" | wc -l | tr -d " "`
	pending_count=`ls pending/zones_with_ds."$date".*.txt | wc -l | tr -d " "`
	if [ x"$tld_count" = x"$pending_count" ]; then
		mv pending/zones_with_ds."$date".*.txt .

		./process_zone.sh zones_with_ds."$date".*.txt | grep '^[a-zA-Z0-9.-]*[[:space:]]*[0-9]*$' | \
			sed 's/^\([a-zA-Z0-9.-]*\)[[:space:]]*\([0-9]*\)$/REPLACE INTO secure_delegation (hoster, day, num) VALUES (#\1#, #'"$date"'#, \2);/' | \
			tr "#" "'" | $mysql

		mv zones_with_ds."$date".*.txt archived
	fi
done
