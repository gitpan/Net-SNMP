# -*- mode: perl -*-
# ============================================================================

package Net::SNMP::Transport::UDP6;

# $Id: UDP6.pm,v 1.0 2004/07/20 13:26:48 dtown Exp $

# Object that handles the UDP/IPv6 Transport Domain for the SNMP Engine.

# Copyright (c) 2004 David M. Town <dtown@cpan.org>
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;

use Net::SNMP::Transport::UDP qw( DOMAIN_UDPIPV6 );

use IO::Socket::INET6;

use Socket6 qw(
   AF_INET6 in6addr_any in6addr_loopback inet_pton getaddrinfo inet_ntop 
   sockaddr_in6
);

## Version of the Net::SNMP::Transport::UDP6 module

our $VERSION = v1.0.0;

## Handle importing/exporting of symbols

use Exporter();

our @ISA = qw( Net::SNMP::Transport::UDP Exporter );

sub import
{
   Net::SNMP::Transport::UDP->export_to_level(1, @_);
}

## RFC 3411 - snmpEngineMaxMessageSize::=INTEGER (484..2147483647)

sub MSG_SIZE_DEFAULT_UDP6() { 1452 } # Ethernet(1500) - IPv6(40) - UDP(8)

# [public methods] -----------------------------------------------------------

sub domain
{
   DOMAIN_UDPIPV6;
}

sub name 
{
  'UDP/IPv6';
}

# [private methods] ----------------------------------------------------------

sub _msg_size_default
{
   MSG_SIZE_DEFAULT_UDP6;
}

sub _addr_any
{ 
   in6addr_any; 
}

sub _addr_loopback
{
   in6addr_loopback; 
}

sub _addr_aton
{
   my ($this, $addr) = @_;

   if ($addr =~ /:/) {

      inet_pton(AF_INET6, $addr); 

   } else {
   
      my @info = getaddrinfo($addr, '');
      
      if (@info == 1) {
         DEBUG_INFO('getaddrinfo(): %s', $info[0]);
         return undef;
      }

      while (@info >= 5) {
         my ($family, $type, $proto, $sin, $cname) = splice(@info, 0, 5);  
         DEBUG_INFO(
            'family = %d, type = %d, proto = %d, sin = %s, cname = %s', 
             $family, $type, $proto, unpack('H*', $sin), ($cname || $addr)
         );
         if ($family == AF_INET6) {
            return (sockaddr_in6($sin))[1];
         }
      }

      undef;
   }

}

sub _addr_ntoa
{
   inet_ntop(AF_INET6, $_[1]);
}

sub _addr_pack
{
   shift; 
   sockaddr_in6(@_); 
}

sub _socket_create
{
   shift;
   IO::Socket::INET6->new(Proto => 'udp', @_);
}

sub DEBUG_INFO
{
   return unless $Net::SNMP::Transport::DEBUG;

   printf(
      sprintf('debug: [%d] %s(): ', (caller(0))[2], (caller(1))[3]) .
      ((@_ > 1) ? shift(@_) : '%s') . 
      "\n",
      @_
   );

   $Net::SNMP::Transport::DEBUG;
}

# ============================================================================
1; # [end Net::SNMP::Transport::UDP6]
