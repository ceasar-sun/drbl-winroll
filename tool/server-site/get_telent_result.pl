#! /usr/bin/perl

##
## Author	: Ceasar Sun , 2011/12/27
## Descript	: get command result from Munin win32 nodes (via DRBL-winroll project)
## Limiation: Not be able to get 'list' result 
## Usage	:
##	#get 'nodes' result from sinle ip
##	 perl -I ~path/for-Net-pm-lib/ this-script --command nodes -ip 192.168.1.1 
##
##	#get 'fetch memory' from multi ips
##	 perl -I ~path/for-Net-pm-lib/ this-script --command nodes 192.168.1.1 192.168.1.8 10.0.0.2
##

use Getopt::Long;
use Net::Telnet;

my ($help, @ip_list, $command);

usage() if (
	@ARGV < 1
	or ! GetOptions('help|?' => \$help, 'ip=s' => \@ip_list, 'command|c=s' => \$command, '<>' => \&push2ip_list )
	or defined $help
	);

foreach $ip (@ip_list) {
	$telnet = new Net::Telnet ( Timeout=>5, Errmode=>'die', Port=>4949 );
	$telnet -> open($ip);
	$telnet -> waitfor('/\n/');
	$telnet -> print("$command");
	($result,$match) = $telnet -> waitfor('/\.\n/');
	print "$result";
	$telnet->close;
}

## Sub function
sub push2ip_list {
	push(@ip_list,$_[0]);
}

sub usage {
	print "Unknown option: @_\n" if ( @_ );
	print "usage: $0 [--ip ip-adress] [--help|-h|?] [--command|-c command (use \"\" to quote with )]\n";
	exit;
}
