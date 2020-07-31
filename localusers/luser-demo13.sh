#!/bin/bash

# This script shows the open network ports on a system
# Use -4 as an argument to limit to tcpv4 ports.

ss -nutl ${1} | grep -v 'Local' | grep ':' | awk '{print $5}' | awk -F ':' '{print $NF}'
