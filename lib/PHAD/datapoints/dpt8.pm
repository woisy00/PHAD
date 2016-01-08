package PHAD::datapoints::dpt8;

sub new {
    my ($class) = @_;

    my $self  = {
        _name => 'DPT_Value_2_Count',
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
    return pack( "CCs>", 0, 0x80, $value );;
}

sub decode {
    my ($self, $value) = @_;
    my @val = split( " ", $value );
    my $val2 = ( hex( $val[0] ) << 8 ) + hex( $val[1] );
    return $val2 > 32767 ? $val2 - 65536 : $val2;
}

1;