package PHAD::datapoints::dpt7;

sub new {
    my ($class) = @_;

    my $self  = {
        _name => 'DPT_Value_2_Ucount',
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
    return pack( "CCS>", 0, 0x80, $value);
}

sub decode {
    my ($self, $value) = @_;
    my @val = split( " ", $value);
    return ( hex( $val[0] ) << 8 ) + hex( $val[1] );
}

1;