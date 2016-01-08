package PHAD::Device;

=pod

=head1 NAME

Device - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = Device->new(
      foo  => 'bar',
      flag => 1,
  );
  
  $object->dummy;

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

=cut

use strict;
use warnings;

use PHAD::DPT;

our $VERSION = '0.01';

=pod

=head2 new

  my $object = Device->new(
      foo => 'bar',
  );

The C<new> constructor lets you create a new B<Device> object.

So no big surprises there...

Returns a new B<Device> or dies on error.

=cut

sub new {
    my $class = shift;
    my ($address, $dptid, $writeCallback) = @_;
    
    my $dpt = PHAD::DPT->new($dptid);
    my $self = bless { 
        _address => $address,
        _dpt => \$dpt,
        _writeCallback => $writeCallback,
        _value => undef,
        _updateListener => undef,
    }, $class;
    return $self;
    
}

=pod

=head2 setDeviceListener

Set the devicelistener.

=cut

sub setUpdateListener {
    my ($self, $listener) = @_;
    $self->{_updateListener} = $listener;
}


=pod
=head setValue

This method is to be called by the PHAD-Daemon if the value should be set to the device.
i.e. by setting the value via CometVisu

=cut
sub setValue {
    my ($self, $newValue ) = @_;
    # maybe set value right here?
    #$self->{_value} = $newValue;
    $self->{_updateCallback}->($newValue);
}

sub valueUpdated {
    my ($self, $newValue ) = @_;
    $self->{_value} = $newValue;
    $self->{_updateListener}->($newValue);
}

sub getDPT {
    my ($self) = @_;
    return ${$self->{_dpt}};
}

sub getAddress {
    my ($self) = @_;
    return $self->{_address};
}

1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Anonymous.

=cut
