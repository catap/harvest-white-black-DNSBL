#!/bin/sh -e

#
# Small script which prepares DNSBL zoens
#

SPAM_FILTER="NOT mailbox Trash* mailbox Junk* SEEN SINCE 7d"
HAM_FILTER="NOT mailbox Trash* NOT mailbox Junk* NOT mailbox virtual.* SEEN SINCE 30d"

BLACKLIST=/var/rbldnsd/bl.local.zone
WHITELIST=/var/rbldnsd/wl.local.zone

# path to used software
DOVEADM=/usr/local/bin/doveadm
EMAIL_RECEIVED_IPS=/usr/local/libexec/harvest-white-black-DNSBL/email-received-ips.pl

SORT=/usr/bin/sort

# doveadm opens all users folders, that requires to enrchive
ulimit -n 1024

# prepare IPs to tmp file
$DOVEADM fetch hdr -A $SPAM_FILTER | $EMAIL_RECEIVED_IPS | $SORT -u > $BLACKLIST.tmp
$DOVEADM fetch hdr -A $HAM_FILTER | $EMAIL_RECEIVED_IPS | $SORT -u > $WHITELIST.tmp

# move it!
mv $BLACKLIST.tmp $BLACKLIST
mv $WHITELIST.tmp $WHITELIST
