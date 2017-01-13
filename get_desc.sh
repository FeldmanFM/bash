#!/bin/bash

printf "%s\t`rpm -qip $1 | sed -n '1,/Description :/!p'`\n" $1
rpm -qip $1 2>/dev/null | grep "Source RPM" | sed 's/^.*Source.*RPM.*\:\s*//g'
