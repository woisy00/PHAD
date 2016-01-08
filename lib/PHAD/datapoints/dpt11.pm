package PHAD::datapoints::dpt11;

sub new {
    my ($class) = @_;

    my $self  = {
        _name => 'DPT_Date',
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
    my %wd = (
        Mo  => 1,
        Di  => 2,
        Mi  => 3,
        Do  => 4,
        Fr  => 5,
        Sa  => 6,
        So  => 7,
        Mon => 1,
        Tue => 2,
        Wed => 3,
        Thu => 4,
        Fri => 5,
        Sat => 6,
        Sun => 7
    );
    my $wdpat = join( '|', keys %wd );
    my ( $w, $h, $m, $s );
    return
      unless ( $w, $h, $m, $s ) =
      ( $value =~
          /^($wdpat)?\s*([0-2][0-9])\:([0-5][0-9])\:?([0-5][0-9])?\s*/si
      );
    return unless defined $h && defined $m;
    $w = $wd{$w} if defined $wd{$w};
    $h += ( $w << 5 ) if $w;
    $s = 0 unless $s;
    return pack( "CCCCC", 0, 0x80, $h, $m, $s );

}

sub decode {
    my ($self, $value) = @_;
    my @val = split( " ", $value);
    my @wd = qw(Null Mo Di Mi Do Fr Sa So);
    $val[0] = hex( $val[0] );
    $val[1] = hex( $val[1] );
    $val[2] = hex( $val[2] );
    unless ( $val[2] ) { return; }
    my $day    = ( $val[0] & 0xE0 ) >> 5;
    my $hour   = $val[0] & 0x1F;
    my $minute = $val[1];
    my $second = $val[2];
    return sprintf( "%s %02i:%02i:%02i", $wd[$day], $hour, $minute, $second );
}

1;