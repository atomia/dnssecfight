#!/bin/sh

if [ -z "$1" ] || [ ! -f "$1" ] ; then
	echo "usage: $0 some.file.tld.txt [ some.other.file.tld.txt ... ]"
	exit
fi

for file in $*; do
	tld=`echo "$file" | tr "a-z" "A-Z" | awk -F . '{ print $(NF-1) }'`

	cat "$file" | awk -vtld="$tld" '
		BEGIN {
			tld_slds["CO"] = 1;
			tld_slds["OR"] = 1;
			tld_slds["COM"] = 1;
			tld_slds["NET"] = 1;
			tld_slds["ORG"] = 1;
			tld_slds["BIZ"] = 1;
			tld_slds["INFO"] = 1;
			tld_slds["EDU"] = 1;
			tld_slds["GOV"] = 1;
	
			delegations = 0
			last_label = ""
			hosters_in_delegation["foo"] = 1
	
			while (getline < "hoster_map") {
				hoster_map[$1] = $2
			}
		}
	
		# Only take delegations
		NF == 3 && $2 == "NS" {
	
			# Keep track of which hosters are in the current delegation
			if (last_label != $1) {
				delete hosters_in_delegation;
				last_label = $1;
				delegations++;
			}
	
			# Make nameserver absolute
			hoster = $3
			if (substr($0, length()) != ".") {
				hoster = hoster "." tld ".";
			}
	
			# Canonicalize hoster
			if (hoster in hoster_map) {
				hoster = hoster_map[hoster]
			} else {
				num = split(hoster, host_parts, ".")
				if (num > 3) {
					sld = host_parts[num - 2];
					if (tld_slds[sld]) {
						sld = host_parts[num - 3] "." sld;
					}
	
					hoster = sld "." host_parts[num - 1] ".";
				}
			}
	
			if (!hosters_in_delegation[hoster]) {
				hosters[hoster]++;
				hosters_in_delegation[hoster] = 1;
			}
		}
	
		END {
			for (hoster in hosters) {
				print hoster " " hosters[hoster];
			}
		}
	'
done | awk '{ hosters[$1] += $2 } END { for (hoster in hosters) print hoster " " hosters[hoster]; }'
