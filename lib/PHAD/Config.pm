package PHAD::Config;

sub new {
    my $class = shift;
    my ($file) = @_;

    my $self = {

        # define instance variables
        # i.e. _var => $var,
        _config_file => $file,
        _data => {},
    };

    bless $self, $class;
    
    if (-e $file) {
        $self->read();
    }
    return $self;
}

sub read {
    my ($self) = @_;
    
    my $cfgfile = $self->{_config_file};
    
    open CONF, "<$cfgfile" || die "Could not open $cfgfile for reading";
    $/ = "\n";

    my $section = '';
    $self->{_data}{$section} = {};

    while (<CONF>) {
        unless ( $_ =~ /\#/ ) {    #checks for uncommented
            # found section! -> section based config file
            if (/^\s*\[\s*(.+?)\s*\]\s*$/) {
                $section = $1;
                $self->{_data}{$section} = {};
            }

            # reads pure config file
            elsif (/^\s*(.+?)\s*\=\s*(.*?)\s*$/) {

                #print $1 ." und ". $2;
                $self->{_data}{$section}{$1} = $2;
            }
        }
    }
    close CONF;
}

sub get {
    my ($self, $param1, $param2) = @_;
    my $section = $param1 if defined $param2;
    my $key = $param2;

    $section = '' unless defined $section;
    $key = $param1 unless defined $key;
    
    return $self->{_data}{$section}{$key};
}

sub set {
    my ($self, $param1, $param2, $param3) = @_;
    
    my $section = $param1 if defined $param3;
    my $key = $param2 if defined $param3;
    my $value = $param3;
    
    $section = '' unless defined $section;
    $key = $param1 unless defined $key;
    $value = $param2 unless defined $value;
    
    $self->{_data}{$section}{$key} = $value;
}


sub write {
    my ($self) = @_;
    
    my $cfgfile = $self->{_config_file};
    
    open CONF, ">$cfgfile" || die "Could not open $cfgfile for writing";

    for my $section (sort keys %{$self->{_data}} ) {
        if ($section eq '') { 
            # do nothing
        } else {
            print CONF "[".$section."]\n";
        }
        my %p = %{$self->{_data}{$section}};
        for my $key (sort keys %p) {
            print CONF $key."=".$p{$key}."\n";
        }
    }
    
    close CONF;
}

sub print {
    my ($self) = @_;
    
    my $cfgfile = $self->{_config_file};
    
    print "File: ".$cfgfile."\n";
    print "Data:\n";
    for my $section (sort keys %{$self->{_data}} ) {
        if ($section eq '') { 
            # do nothing
            print "Root:\n";
        } else {
            print "[".$section."]\n";
        }
        my %p = %{$self->{_data}{$section}};
        for my $key (sort keys %p) {
            print $key."=".$p{$key}."\n";
        }
    }
}

1;