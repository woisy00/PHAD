package PHAD::datapoints::dpt1;

sub new {
    my $class = shift;

    my $self  = {
        _name => 'DPT_Switch',
    };

    bless $self, $class;
    
    return $self;
}

sub getName {
    my ($self) = @_;
    return $self->{_name};
}

sub encode {
    my ( $self, $value ) = @_;

    #      '1.001': {
    #    name  : 'DPT_Switch',
    #    encode: function( phy ){
    #      return (phy | 0x80).toString( 16 );
    #    },
    #    decode: function( hex ){
    #      return parseInt( hex , 16 );
    #    }
    #  },
    return pack( "CC", 0, $value | 0x80 );    #send 6bit small     
}

sub decode {
    my ($self, $value) = @_;
    return int($value);
}

sub decode_dpt2 { #2bit "signed bit"
    my $val=hex(shift) & 0x03;
    return $val > 1 ? $val-4 : $val;
}

sub decode_dpt3 { #4bit signed integer
    my $val=hex(shift) & 0x0f;
    return $val > 7 ? 8-$val : $val;
}
1;