package PHAD::datapoints::dpt9;

sub new {
    my ($class) = @_;

    my $self  = {
        _name => 'DPT_Value_Temp',
    };

    bless $self, $class;
    
    return $self;
}

sub getName {
    my ($self) = @_;
    return $self->{_name};
}

sub doEncode {
    my ($self, $value) = @_;
    my $data;

    my $sign = ( $value < 0 ? 0x8000 : 0 );
    my $exp  = 0;
    my $mant = 0;

    $mant = int( $value * 100.0 );
    while ( abs($mant) > 2047 ) {
        $mant /= 2;
        $exp++;
    }
    $data = $sign | ( $exp << 11 ) | ( $mant & 0x07ff );
    return $data >> 8, $data & 0xff;
}

sub encode {
    my ($self, $value) = @_;
    return pack( "CCCC", 0, 0x80, doEncode($value) );
}


sub decode {
    my ($self, @value) = @_;
    my $res;

    unless ( $#value == 2 ) {
        ( $value[1], $value[2] ) = split( ' ', $value[0] );
        $value[1] = hex $value[1];
        $value[2] = hex $value[2];
        unless ( defined $value[2] ) {
            return;
        }
    }
    my $sign = $value[1] & 0x80;
    my $exp  = ( $value[1] & 0x78 ) >> 3;
    my $mant = ( ( $value[1] & 0x7 ) << 8 ) | $value[2];

    $mant = -( ~( $mant - 1 ) & 0x7ff ) if $sign != 0;
    $res = ( 1 << $exp ) * 0.01 * $mant;
    return $res;
}

1;