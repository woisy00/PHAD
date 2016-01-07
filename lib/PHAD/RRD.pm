package PHAD::RRD;

use strict;
use warnings;
#use RRDs;

our $VERSION = '1.00';

my $rrd_interval = 300;
my $rra1_row = 2160;
my $rra5_row = 2016;
my $rra15_row = 2880;
my $rra180_row = 8760;

my $rrd_lastupdate = time()-($rrd_interval-+1);
my $rrd_syslastupdate = time()-($rrd_interval-+1);


sub new {
    my $class = shift;
    my ($logger, $rrd_dir) = @_;

    my $self  = bless { 
        _logger => $logger,
        _rrd_dir => $rrd_dir,
        
    }, $class;
    return $self;
}


sub update_rrd {
#    my $self = shift;
#    my ($key,$suffix,$value,$valtype,$stephours,$rrasteps) = @_;
#    return unless defined $value;
#    $valtype = "GAUGE" unless $valtype;
#    $stephours = 24 unless $stephours;
#    
#    my $rrd_dir = $self->{_rrd_dir};
#    
#    if (!-d $rrd_dir) { mkdir($rrd_dir); }
#    if (!-e $rrd_dir . $key . $suffix .'.rrd') {
#        # Checkvalue-type for boundries?
#        # Create RRD
#        if ($valtype eq "GAUGE"){
#            my $heartbeat = $rrd_interval * 3;
#            RRDs::create($rrd_dir.$key.$suffix .'.rrd',
#            '--step' => $rrd_interval,
#            'DS:value:'.$valtype.':'.$heartbeat.':-55:255000',
#            'RRA:AVERAGE:0.5:1:'.$rra1_row,'RRA:AVERAGE:0.5:5:'.$rra5_row,'RRA:AVERAGE:0.5:15:'.$rra15_row,'RRA:AVERAGE:0.5:180:'.$rra180_row,
#            'RRA:MIN:0.5:1:'.$rra1_row,'RRA:MIN:0.5:5:'.$rra5_row,'RRA:MIN:0.5:15:'.$rra15_row,'RRA:MIN:0.5:180:'.$rra180_row,
#            'RRA:MAX:0.5:1:'.$rra1_row,'RRA:MAX:0.5:5:'.$rra5_row,'RRA:MAX:0.5:15:'.$rra15_row,'RRA:MAX:0.5:180:'.$rra180_row);
#            if (RRDs::error) {
#                $self->{_logger}-> info("Create RRDs failed for $key$suffix :".RRDs::error);
#            } else {
#                $self->{_logger}-> info("Created RRD for $key$suffix");
#            }
#        }
#        elsif ($valtype eq "COUNTER"){
#            $rrasteps = 7 unless $rrasteps;
#            RRDs::create ($rrd_dir.$key.$suffix .'.rrd',
#            'DS:value:'.$valtype.':'.(($stephours*3600)+600).':0:10000000000',
#            'RRA:AVERAGE:0.5:1:1826', 'RRA:AVERAGE:0.5:'.$rrasteps.':1300',
#            'RRA:MIN:0.5:1:1826',     'RRA:MIN:0.5:'.$rrasteps.':1300',
#            'RRA:MAX:0.5:1:1826',     'RRA:MAX:0.5:'.$rrasteps.':1300',
#            '-s '.($stephours*3600));
#            if (RRDs::error) {
#                $self->{_logger}-> info("Create RRDs failed for $key$suffix :".RRDs::error);
#            } else {
#                $self->{_logger}-> info("Created RRD for $key$suffix");
#            }
#        }
#    }
#    
#    # Update values
#    $value = int($stephours*3600*$value) if ($valtype eq "COUNTER");
#    RRDs::update($rrd_dir.$key.$suffix.'.rrd','N:'.$value);
#    
#    if (RRDs::error) {
#        $self->{_logger}->info("Update of RRDs failed for $key$suffix/$value:".RRDs::error);
#        # FIXME: Check if error comes from update-value or from rrd-file!
#        #rename ($rrd_dir.$key.$suffix.'.rrd',$rrd_dir.$key.$suffix.'.rrd.old');
#    } else {
#        $self->{_logger}->debug("Updated RRD for $key$suffix/$value");
#    }
}

=pod
 
 =head1 NAME
 
 WireGate Daemon
 
 =head1 SYNOPSIS
 
 daemon to handle gateway/communication-functions
 
 =head1 CREDITS
 
 Parts copyright by Martin Koegler from bcusdk/eibd (GPL)
 Parts copyright by various from misterhouse (GPL)
 
 =head1 HISTORY
 
 2008-12-09  Initial versions of wg-ow2eib.pl and wg-eiblis.pl
 see SVN
 
 =cut