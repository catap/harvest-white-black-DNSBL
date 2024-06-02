#!/usr/bin/env perl

=head1 NAME

email-received-ips.pl - Dumps received IPs and RNDS from an email

=head1 SYNOPSIS

It expects an email or emails which is separated as 0x0a0x0a0x0cx0a to
STDIN and prints the first public IP and its RDNS which is found in
Received headers.

It compatible with doveadm, so you may run:

  doveadm fetch hdr -A mailbox Junk SINCE 7d | email-received-ips.pl | sort -u

to get IPs and RDNS records associeted with emails in Junk folders of
all accounts for the last week.

Output format is compatible with rbldnsd dnset zone.

=cut

use strict;

use feature "say";

use Email::Simple;
use Email::Received;

use Net::IP;

{
    local $/ = "\x{0a}\x{0a}\x{0c}\x{0a}";

    while (<>) {
        my $email = Email::Simple->new($_);
        for ($email->header("Received")) {
            my $data = parse_received($_);
            my $ip = $data->{ip} or next;
            my $ip = new Net::IP($ip) or next;
            $ip->iptype() eq 'PUBLIC' or next;
            say join ".", reverse split /\./, $data->{ip};
            say $data->{rdns} if $data->{rdns};
            last;
        }
    }
}
