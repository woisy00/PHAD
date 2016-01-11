package PHAD::Plugin;

use PHAD::Device;
use PHAD::Logger;

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

sub setCycleTime {
    my ($self, $cycleTime) = @_;
    $self->{_cycleTime} = $cycleTime;        
}

sub getCycleTime {
    my ($self) = @_;
    return $self->{_cycleTime};
}

sub getName {
    my ($self) = @_;
    return ref $self;
}

sub getLogger {
    my ($self) = @_;
    return ${$self->{_logger}} if defined $self->{_logger};
    return $self->{_phad}->getLogger();
}

sub StartCycling {
    my ($self, $port) = @_;
    my $childPid = fork();
    
    die "Could not fork child process!" unless defined $childPid;
     
    if ($childPid == 0) {
        use RPC::Lite::Client;

        my $client = RPC::Lite::Client->new({
            Transport  => 'TCP:Host=localhost,Port=10000',
            Serializer => 'JSON', # JSON is actually the default,
                                    # this argument is unnecessary
        });
        
        # child process  
        $SIG{TERM} = sub {
            if ($self->can('shutdown')) {
                $self->shutdown();
            }
            exit();
        };
        $SIG{KILL} = sub {
            if ($self->can('shutdown')) {
                $self->shutdown();
            }            
            exit();
        };
         
        if ($self->can('startup')) {
            $self->startup();
        }
        while (1) {
            my $pluginLogger = PHAD::Logger->new(1);
            $self->{_logger} = \$pluginLogger;
            
            if ($self->can("execute")) {
                $self->getLogger()->debug("Executing ".$self->getName());
                $self->execute();
            }
            
            if ($self->{_devices}) {
                my %devices = %{$self->{_devices}};
                foreach my $device (values %devices) {
                    my $tmpDevice = ${$device}; 
                    if ($tmpDevice->can("execute")) {
                        my $deviceType = ref $tmpDevice;
                        $self->getLogger()->debug("Executing Device ".$tmpDevice->getAddress." of Type ".$tmpDevice);
                        $tmpDevice->execute();
                    }
                }
            }
            sleep $self->getCycleTime();
        }
        
    
    }
    
}

#sub execute {
#    my ($self) = @_;
#    
#    my $device = $self->{_device}; 
#    $device->valueUpdated($device->getDPT()->encode(0));
#}

1;