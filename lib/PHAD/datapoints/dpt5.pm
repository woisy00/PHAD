package PHAD::datapoints::dpt5;

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
    $value = 100 if ( $value > 100 );
    $value = 0   if ( $value < 0 );
    my $byte = sprintf( "%.0f", $value * 255 / 100 );
    return ($byte);
}

sub decode {
    my ($self, $value) = @_;
    return sprintf( "%.1f", hex($value) * 100 / 255 );
}

1;