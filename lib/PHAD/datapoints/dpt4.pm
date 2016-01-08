package PHAD::datapoints::dpt4;

sub new {
    my $class = shift;

    my $self  = {
        _name => 'DPT_Char_ASCII',
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
    return pack( "CCc", 0, 0x80, ord($value) );
}

sub decode {
    my ($self, $value) = @_;
        #    encode: function( phy ){
    #      var val = phy.charCodeAt( 0 ).toString( 16 );
    #      return (val.length == 1 ? '800' : '80') + val;
    #    },
    #    decode: function( hex ){
    #      return String.fromCharCode(parseInt( hex, 16 ));
    #    }
    return sprintf( "%c", hex($value) );
}

1;