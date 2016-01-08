package PHAD::Daemon;

our $VERSION = '0.01';

use strict;

use Time::HiRes qw ( time alarm sleep usleep gettimeofday );


use PHAD::Device;
use PHAD::RRD;
use PHAD::Logger;
use Module::Pluggable::Object;

use Data::Dumper;

sub new {
    my $class = shift;
    my ($config_file, $debug) = @_;
    
    my $cfg = PHAD::Config->new($config_file);
    # make shure config file exists!
    $cfg->read();
    
    my $cycle = $cfg->get('cycle_time');
    
    my $plugin_dir = $cfg->get('plugin_dir');
    
    $cycle = 60 unless defined $cycle;

    my $self  = { 
        _logger => PHAD::Logger->new($debug),
        _cycle => $cycle,
        _devices => {},
        _plugins => undef,
        _cfg => \$cfg,
    };

    bless $self, $class;
    
    $self->loadPlugins();
    return $self;
}

sub getConfigDir {
    my ($self) = @_;
    return ${$self->{_cfg}}->get('config_dir');
}

sub registerDevice {
    my ($self, $device) = @_;
    
    my $address = $device->getAddress();
    my %devices = %{$self->{_devices}};
    $devices{$address} = \$device;
    $device->setUpdateListener(sub {
        print "Update Value: ".Dumper(\@_)."\n";
        my ($value) = @_;
        $self->{_logger}->info("Device ".$device->getAddress." updated to ".$device->getDPT()->decode($value)." raw (".$value.")");
    });
}


sub loadPlugins {
    my $self = shift;
    # Save list of created plugin objects
    my $finder = Module::Pluggable::Object->new(
            search_path => ['PHAD::Plugin'], 
            instantiate => 'new', 
            search_dirs => ${$self->{_cfg}}->get('plugin_dir'),
    );
    
    my @loaded = $finder->plugins($self);
    $self->{_plugins} = \@loaded;
    $self->{_logger}->info("Loaded ".@loaded." plugins.");
}

sub mainLoop {
    my $self = shift;
    
    while (1) {
        $self->{_logger}->debug("Executing main loop");
        
        my @loaded_plugins = @{ $self->{_plugins} };
        foreach my $plugin (@loaded_plugins) {
            if ($plugin->can("execute")) {
                my $pluginName = ref $plugin;
                $self->{_logger}->debug("Executing ".$pluginName);
                $plugin->execute();
            }
            
        }
        
        if ($self->{_devices}) {
            my %devices = %{$self->{_devices}};
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