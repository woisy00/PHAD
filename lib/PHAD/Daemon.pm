package PHAD::Daemon;

our $VERSION = '0.01';

use strict;

use Time::HiRes qw ( time alarm sleep usleep gettimeofday );


use PHAD::Device;
use PHAD::RRD;
use PHAD::Logger;
use Module::Pluggable::Object;

our @ISA = qw(RPC::Lite::Server);

sub new {
    my $class = shift;
    my ($config_file, $debug) = @_;
    my $self;
    
    my $cfg = PHAD::Config->new($config_file);
    # make shure config file exists!
    $cfg->read();
    
    my $cycle = $cfg->get('cycle_time');
    
    my $plugin_dir = $cfg->get('plugin_dir');
    
    $cycle = 60 unless defined $cycle;

    my %devices = ();
    
    $self = $class->SUPER::new({
        Transports  => [ 'TCP:Port=10000' ],
        Threaded    => 1,
    });
    
    my $logger = PHAD::Logger->new($debug);
    #$self->AddSignature('getValues=hash:int,int'); # signatures are optional)
    $self->{_logger} = $logger;
    $self->{_cycle} = $cycle;
    $self->{_devices} = \%devices;
    $self->{_plugins} = undef;
    $self->{_cfg} = \$cfg;

    bless $self, $class;
    $self->loadPlugins();

    return $self;
}

sub getLogger {
    my ($self) = @_;
    return ${$self->{_logger}};
}

sub getConfigDir {
    my ($self) = @_;
    return ${$self->{_cfg}}->get('config_dir');
}


sub getDevice {
    my ($self, $address) = @_;
    return ${$self->{_devices}{$address}};
}

sub registerDevice {
    my ($self, $device) = @_;
    
    my $address = $device->getAddress();
    $self->{_devices}{$address} = \$device;
    $device->setUpdateListener(sub {
        #print "Update Value: ".Dumper(\@_)."\n";
        my ($value) = @_;
        $self->{_logger}->info("Device ".$device->getAddress." updated to ".$device->getDPT()->decode($value)." raw (".$value.")");
    });
}

sub getValue {
    my ($self, $address) = @_;
    my %devices = %{$self->{_devices}};
    return $self->getDevice($address)->getValue();
}

sub setValue {
    my ($self, $address, $value) = @_;
    $self->getDevice()->setValue($value);
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
    
    $SIG{TERM} = sub {
        # -> Doesn't work when blocked by I/O!!
        #LOGGER('DEBUG',"Thread eiblisten Caught TERM, exiting:". $thr_eiblisten_cause);
        #system ("touch $alive"); # avoid timeout for init
        #if($eib_logging) { close FILE_EIBLOG; }
        #$plugindb->sync(); # write out
        #`cp $ramdisk$plugin_db_name $plugin_db_path$plugin_db_name`;
        exit();
    };
    $SIG{KILL} = sub {
        # ende aus finito
        #LOGGER('DEBUG',"Thread eiblisten Caught KILL, exiting:" .$thr_eiblisten_cause);
        #system ("touch $alive"); # avoid timeout for init
        #if($eib_logging) { close FILE_EIBLOG; }
        #$plugindb->sync(); # write out
        #`cp $ramdisk$plugin_db_name $plugin_db_path$plugin_db_name`;
        exit();
    };
    
        
    $self->{_logger}->debug("Starting plugins");
    
    my @loaded_plugins = @{ $self->{_plugins} };
    foreach my $plugin (@loaded_plugins) {
        my $pluginName = ref $plugin;
        $self->{_logger}->debug("Starting ".$pluginName);
        $plugin->StartCycling();
    }
    
    $self->Loop;    
}

1;