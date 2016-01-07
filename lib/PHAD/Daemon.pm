package PHAD::Daemon;

our $VERSION = '0.01';

use strict;

use Time::HiRes qw ( time alarm sleep usleep gettimeofday );


use PHAD::Device;
use PHAD::RRD;
use PHAD::Logger;
use Module::Pluggable search_path => ['plugins'], instantiate => 'new';
# search_dirs => $self->{_plugin_path}, 


sub new {
    my $class = shift;
    my ($plugin_path, $debug, $cycle) = @_;
    

    my $self  = { 
        _logger => PHAD::Logger->new($debug),
        _cycle => $cycle,
        _devices => undef,
        _plugins => undef,
        _plugin_path => $plugin_path,
    };

    bless $self, $class;
    
    $self->loadPlugins();
    return $self;
}


sub loadPlugins {
    my $self = shift;
    # Save list of created plugin objects
    my @loaded = $self->plugins($self);
    $self->{_plugins} = \@loaded;
    $self->{_logger}->info("Loaded ".@loaded." plugins.");
    
    if ($self->{_devices}) {
        my %devices = $self->{_devices};
        foreach my $device (values %devices) { 
            $device->setUpdateListener(sub {
                $self->{_logger}->info("Device $device->getAddress updated...");
            });
        }
    }
}

sub mainLoop {
    my $self = shift;
    
    while (1) {
        $self->{_logger}->debug("Executing main loop");
        
        my $w = plugins::Weather->new($self);
        $w->run_PHAD_plugin();
        
        my @loaded_plugins = @{ $self->{_plugins} };
        foreach my $plugin (@loaded_plugins) {
            if ($plugin->can("run_PHAD_plugin")) {
                my $pluginName = ref $plugin;
                $self->{_logger}->debug("Executing ".$pluginName);
                $plugin->run_PHAD_plugin();
            }
            
        }
        
        if ($self->{_devices}) {
            my %devices = $self->{_devices};
            foreach my $device (values %devices) { 
                if ($device->can("execute")) {
                    my $deviceType = ref $device;
                    $self->{_logger}->debug("Executing Device ".$device->getAddress." of Type ".$deviceType);
                    $device->execute;
                }
            }
        }
        sleep $self->{_cycle};
    }
}

1;