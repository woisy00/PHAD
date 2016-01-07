package PHAD::Logger;

=pod

=head1 NAME

logger - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = logger->new(
      foo  => 'bar',
      flag => 1,
  );
  
  $object->dummy;

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

=cut

use 5.010;
use strict;
use warnings;

use Time::HiRes qw ( time alarm sleep usleep gettimeofday );

our $VERSION = '0.01';

=pod

=head2 new

  my $object = logger->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<logger> object.

So no big surprises there...

Returns a new B<logger> or dies on error.

=cut

sub new {
    my $class = shift;
    my ($debug) = @_;
    my $self  = bless { 
        _debug => $debug,
    }, $class;
        # if($eib_logging) { close FILE_EIBLOG; }
        # $plugindb->sync(); # write out
        # `cp $ramdisk$plugin_db_name $plugin_db_path$plugin_db_name`;
    # $SIG{TERM} = sub {
        # -> Doesn't work when blocked by I/O!!
        # $logger->info("Thread eiblisten Caught TERM, exiting:". $thr_eiblisten_cause);
        # exit();
    # };
    # $SIG{KILL} = sub {
        # ende aus finito
        # $logger->info("Thread eiblisten Caught KILL, exiting:" .$thr_eiblisten_cause);
        # exit();
    # };

    return $self;
}

sub getISODateStamp { # Timestamps for Logs
    my ($eseconds,$msec) = gettimeofday();
    my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime($eseconds);
    return sprintf "%04d-%02d-%02d %02d:%02d:%02d.%03d", ($yearOffset+1900),($month+1),$dayOfMonth,$hour,$minute,$second,$msec/1000;
}

=pod

=head2 dummy

This method does something... apparently.

=cut

sub log($$){# LOG-sub to replace heavyweight Log4Perl/Syslog
    my ($self, $level, $msg) = @_;
    
    if ($level eq "DEBUG") {
        return unless $self->{_debug};
    }
    if ($self->{_debug}) {
        print STDERR getISODateStamp . " $level - $msg\n";
    } else {
        `logger -t $0 -p $level "$level - $msg"`;
    }
}
1;



sub info {
    my ($self, $msg) = @_;
    $self->log('INFO', $msg);
}


sub debug {
    my ($self, $msg) = @_;
    $self->log('DEBUG', $msg);
}


sub warn {
    my ($self, $msg) = @_;
    $self->log('WARN', $msg);
}

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Anonymous.

=cut
