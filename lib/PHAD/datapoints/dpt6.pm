package PHAD::datapoints::dpt6;

sub new {
    my ($class) = @_;

    my $self  = {
        _name => 'DPT_Percent_V8',
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
    return pack( "CCc",  0, 0x80, $value );
}

sub decode {
    my ($self, $value) = @_;
    my $val = hex($value);
    return $val > 127 ? $val - 256 : $val;
}

1;