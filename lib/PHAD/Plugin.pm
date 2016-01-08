package PHAD::Plugin;

use PHAD::Device;

sub new {
    my $class = shift;
    my ($phad) = @_;
    
    my $self = bless { 
        _phad => $phad,
        _devices => {},
    }, $class;
    
    return $self;
}

sub registerDevice {
    my ($self, $device) = @_;
    
    my $address = $device->getAddress();
    $self->{_devices}{$address} = \$device;
    $self->{_phad}->registerDevice($device);
}

sub getDevice {
    my ($self, $address) = @_;
    return ${$self->{_devices}{$address}};
}

#sub execute {
#    my ($self) = @_;
#    
#    my $device = $self->{_device}; 
#    $device->valueUpdated($device->getDPT()->encode(0));
#}

1;