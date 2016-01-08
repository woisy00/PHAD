package PHAD::datapoints::dpt5_10;

sub new {
    my ($class, $name) = @_;

    my $self  = {
        _name => $name,
    };

    bless $self, $class;
    
    return $self;
}


sub getName {
    my ($self) = @_;
    return $self->{_name};
}

sub encode {
    my ($self, $value) = @_;
    return pack( "CCC", 0, 0x80, $value );
}

sub decode {
    my ($self, $value) = @_;
    return hex($value);
}

1;