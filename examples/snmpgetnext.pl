#! /usr/local/bin/perl 

eval '(exit $?0)' && eval 'exec /usr/local/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/local/bin/perl $0 $argv:q'
if 0;

# ============================================================================

# $Id: snmpgetnext.pl,v 2.2 2004/07/20 13:38:01 dtown Exp $

# Copyright (c) 2000-2004 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use Net::SNMP v5.0.0 qw(snmp_type_ntop DEBUG_ALL);
use Getopt::Std;

use strict;
use vars qw($SCRIPT $VERSION %OPTS);

$SCRIPT  = 'snmpgetnext';
$VERSION = '2.2.0';

# Validate the command line options
if (!getopts('a:A:c:dD:E:m:n:p:r:t:u:v:x:X:', \%OPTS)) {
   _usage();
}

# Do we have enough information?
if (@ARGV < 2) {
   _usage();
}

# Create the SNMP session
my ($s, $e) = Net::SNMP->session(
   -hostname  => shift,
   exists($OPTS{a}) ? (-authprotocol =>  $OPTS{a}) : (),
   exists($OPTS{A}) ? (-authpassword =>  $OPTS{A}) : (),
   exists($OPTS{c}) ? (-community    =>  $OPTS{c}) : (),
   exists($OPTS{D}) ? (-domain       =>  $OPTS{D}) : (),
   exists($OPTS{d}) ? (-debug        => DEBUG_ALL) : (),
   exists($OPTS{m}) ? (-maxmsgsize   =>  $OPTS{m}) : (),
   exists($OPTS{p}) ? (-port         =>  $OPTS{p}) : (),
   exists($OPTS{r}) ? (-retries      =>  $OPTS{r}) : (),
   exists($OPTS{t}) ? (-timeout      =>  $OPTS{t}) : (),
   exists($OPTS{u}) ? (-username     =>  $OPTS{u}) : (),
   exists($OPTS{v}) ? (-version      =>  $OPTS{v}) : (),
   exists($OPTS{x}) ? (-privprotocol =>  $OPTS{x}) : (),
   exists($OPTS{X}) ? (-privpassword =>  $OPTS{X}) : ()
);

# Was the session created?
if (!defined($s)) {
   _exit($e);
}

my @args = (
   exists($OPTS{E}) ? (-contextengineid => $OPTS{E}) : (),
   exists($OPTS{n}) ? (-contextname     => $OPTS{n}) : (),
   -varbindlist    => \@ARGV
);

# Send the SNMP message
if (!defined($s->get_next_request(@args))) {
   _exit($s->error());
}

# Print the results
foreach ($s->var_bind_names()) {
   printf(
      "%s = %s: %s\n", $_,
      snmp_type_ntop($s->var_bind_types()->{$_}),
      $s->var_bind_list()->{$_},
   );
}

# Close the session
$s->close();
 
exit 0;

# [private] ------------------------------------------------------------------

sub _exit
{
   printf join('', sprintf("%s: ", $SCRIPT), shift(@_), ".\n"), @_;
   exit 1;
}

sub _usage
{
   print << "USAGE";
$SCRIPT v$VERSION
Usage: $SCRIPT [options] <hostname> <oid> [...]
Options: -v 1|2c|3      SNMP version
         -d             Enable debugging
   SNMPv1/SNMPv2c:
         -c <community> Community name
   SNMPv3:
         -u <username>  Username (required)
         -E <engineid>  Context Engine ID
         -n <name>      Context Name
         -a <authproto> Authentication protocol <md5|sha>
         -A <password>  Authentication password
         -x <privproto> Privacy protocol <des|3des|aes128|aes192|aes256>
         -X <password>  Privacy password
   Transport Layer:
         -D <domain>    Domain <udp4|udp6|tcp4|tcp6>
         -m <octets>    Maximum message size
         -p <port>      Destination UDP port
         -r <attempts>  Number of retries
         -t <secs>      Timeout period
USAGE
   exit 1;
}

# ============================================================================

