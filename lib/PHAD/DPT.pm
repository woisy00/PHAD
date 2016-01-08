package PHAD::DPT;

use strict;
use warnings;

use feature "switch";
no warnings 'experimental';
our $VERSION = '1.00';

sub new {
    my $class = shift;
    my ($dptid) = @_;

    my $self = bless {
        _dptid => $dptid,
        _datapoint => undef,
    }, $class;
    $self->parse();
    return $self;
}

sub parse {
    my ($self) = @_;

    my $datapoint;
    given ( $self->{_dptid} ) {
        when (['1', '1.001', '1.002', '1.003', '1.008', '1.009', '2', '3']) {
            use PHAD::datapoints::dpt1;
            $datapoint = PHAD::datapoints::dpt1->new();
        }

        when (['4', '4.001']) {
            use PHAD::datapoints::dpt1;
            $datapoint = PHAD::datapoints::dpt4->new();
        }

        when ('5') {
            use PHAD::datapoints::dpt5;
            $datapoint = PHAD::datapoints::dpt5->new('8-Bit Unsigned Value');
        }
        when ('5.001') { 
            use PHAD::datapoints::dpt5;
            $datapoint = PHAD::datapoints::dpt5->new('DPT_Scaling');
        }
        
        when ('5.003') {
            use PHAD::datapoints::dpt5_10;
            $datapoint = PHAD::datapoints::dpt5_10->new('DPT_Angle');
        }
        when ('5.004') {
            use PHAD::datapoints::dpt5_10;
            $datapoint = PHAD::datapoints::dpt5_10->new('DPT_Percent_U8');
        }
        when ('5.010') {
            use PHAD::datapoints::dpt5_10;
            $datapoint = PHAD::datapoints::dpt5_10->new('DPT_Value_1_Ucount');
        }

        when (['6', '6.001']) {
            use PHAD::datapoints::dpt6;
            $datapoint = PHAD::datapoints::dpt6->new();
        }

        when (['7', '7.001']) {
            use PHAD::datapoints::dpt7;
            $datapoint = PHAD::datapoints::dpt7->new();
        }
        
        when (['8', '8.001']) {
            use PHAD::datapoints::dpt8;
            $datapoint = PHAD::datapoints::dpt8->new();
        }
        
        when (['9', '9.001', '9.004', '9.007', '9.008', '9.020', '9.021']) {
            use PHAD::datapoints::dpt9;
            $datapoint = PHAD::datapoints::dpt9->new();
        }

        when ('10.001') {
            use PHAD::datapoints::dpt10;
            $datapoint = PHAD::datapoints::dpt10->new();
        }

        when ('11.001') {
            use PHAD::datapoints::dpt11;
            $datapoint = PHAD::datapoints::dpt11->new();
        }

        when (['12', '12.001']) {

    #    name  : 'DPT_Value_4_Ucount',
        }

        when (['13', '13.001']) {
          #    name  : 'DPT_Value_4_Count',
        }

        when ('14') {

            #    link  : '14.001',
            #    name  : '4 byte float',
            #    lname
            #      'de': '4 Byte Gleitkommazahl'
            #    },
            #    unit  : '-'
        }
        when ('14.001') {

            #    name  : 'DPT_Value_Acceleration_Angular',
            #    encode: function( phy ){
            #      //FIXME: unimplemented (jspack?)
            #    },
            #    decode: function( hex ){
            #      var val = parseInt( hex, 16 );
            #      var sign = (val & 0x80000000) ? -1 : 1;
            #      var exp  =((val & 0x7F800000) >> 23) - 127;
            #      var mant = (val & 0x007FFFFF | 0x00800000);
            #      return sign * Math.pow( 2, exp ) * ( mant / (1 << 23));
            #    }
        }
        when (['16', '16.000', '16.001']) {

          #    name  : 'DPT_String_8859_1',
        }

        default {
            use PHAD::datapoints::dpt1;
            $datapoint = PHAD::datapoints::dpt1->new();
        }
    }
    $self->{_datapoint} = \$datapoint;
}

sub decode_dpt11 {    #3byte date
    my @val = split( " ", shift );
    my @wd = qw(Null Mo Di Mi Do Fr Sa So);
    $val[0] = hex( $val[0] );
    $val[1] = hex( $val[1] );
    $val[2] = hex( $val[2] );
    unless ( $val[2] ) { return; }
    my $mday = $val[0] & 0x1F;
    my $mon  = $val[1] & 0x0F;
    my $year = $val[2] & 0x7F;
    $year = $year < 90 ? $year + 2000 : $year + 1900;    # 1990 - 2089
    return sprintf( "%04i-%02i-%02i", $year, $mon, $mday );
}

sub decode_dpt12 {                                       #4byte unsigned
    my @val = split( " ", shift );
    return ( hex( $val[0] ) << 24 ) +
      ( hex( $val[1] ) << 16 ) +
      ( hex( $val[2] ) << 8 ) +
      hex( $val[3] );
}

sub decode_dpt13 {                                       #4byte signed
    my @val = split( " ", shift );
    my $val2 =
      ( hex( $val[0] ) << 24 ) +
      ( hex( $val[1] ) << 16 ) +
      ( hex( $val[2] ) << 8 ) +
      hex( $val[3] );
    return $val2 > 2147483647 ? $val2 - 4294967296 : $val2;
}

sub decode_dpt14 {                                       #4byte float
        #Perls unpack for float is somehow strange broken
    my @val = split( " ", shift );
    my $val2 =
      ( hex( $val[0] ) << 24 ) +
      ( hex( $val[1] ) << 16 ) +
      ( hex( $val[2] ) << 8 ) +
      hex( $val[3] );
    my $sign = ( $val2 & 0x80000000 ) ? -1 : 1;
    my $expo = ( ( $val2 & 0x7F800000 ) >> 23 ) - 127;
    my $mant = ( $val2 & 0x007FFFFF | 0x00800000 );
    my $num  = $sign * ( 2**$expo ) * ( $mant / ( 1 << 23 ) );
    return sprintf( "%.4f", $num );
}

sub decode_dpt16 {    # 14byte char
    my @val = split( " ", shift );
    my $chars;
    for ( my $i = 0 ; $i < 14 ; $i++ ) {
        $chars .= sprintf( "%c", hex( $val[$i] ) );
    }
    return sprintf( "%s", $chars );
}

sub decode {
    my ($self, $data) = @_;
    $data =~ s/\s+$//g;
    return ${$self->{_datapoint}}->decode($data);
}

sub encode {
    my ($self, $value) = @_;
    
    return ${$self->{_datapoint}}->encode($value);

 #     DPT 1 (1 bit) = EIS 1/7 (move=DPT 1.8, step=DPT 1.7)
 #     DPT 2 (1 bit controlled) = EIS 8
 #     DPT 3 (3 bit controlled) = EIS 2
 #     DPT 4 (Character) = EIS 13
 #     DPT 5 (8 bit unsigned value) = EIS 6 (DPT 5.1) oder EIS 14.001 (DPT 5.10)
 #     DPT 6 (8 bit signed value) = EIS 14.000
 #     DPT 7 (2 byte unsigned value) = EIS 10.000
 #     DPT 8 (2 byte signed value) = EIS 10.001
 #     DPT 9 (2 byte float value) = EIS 5
 #     DPT 10 (Time) = EIS 3
 #     DPT 11 (Date) = EIS 4
 #     DPT 12 (4 byte unsigned value) = EIS 11.000
 #     DPT 13 (4 byte signed value) = EIS 11.001
 #     DPT 14 (4 byte float value) = EIS 9
 #     DPT 15 (Entrance access) = EIS 12
 #     DPT 16 (Character string) = EIS 15
#    given ( $self->{_dptid} ) {
#
#        when (/^11/) {
#            my ( $y, $m, $d );
#            return
#              unless ( $y, $m, $d ) = ( $value =~
#                  /^([1-2][0-9][0-9][0-9])\-([0-1][0-9])\-([0-3][0-9])\s*/si );
#            return if $y < 1990 || $y >= 2090;
#            $y %= 100;
#            $bytes = pack( "CCCCC", 0, $apci, $d, $m, $y );
#        }
#        when (/^12/) {
#            $bytes = pack( "CCL>", 0, $apci, $value );
#        }    #EIS11.000/DPT12 (4 byte unsigned)
#        when (/^13/) { $bytes = pack( "CCl>",  0, $apci, $value ); }
#        when (/^14/) { $bytes = pack( "CCf>",  0, $apci, $value ); }
#        when (/^16/) { $bytes = pack( "CCa14", 0, $apci, $value ); }
#        when (/^17/) { $bytes = pack( "CCC",   0, $apci, $value & 0x3F ); }
#        when (/^20/) { $bytes = pack( "CCC",   0, $apci, $value ); }
#
#        default {
#            $self->{_logger}
#              ->warn("None or unsupported DPT: $self->{_dptid} value $value");
#            return;
#        }
#    }
#    return $bytes;
}

1;

=pod
 
 =head1 NAME
 
 WireGate Daemon
 
 =head1 SYNOPSIS
 
 daemon to handle gateway/communication-functions
 
 =head1 CREDITS
 
 Parts copyright by Martin Koegler from bcusdk/eibd (GPL)
 Parts copyright by various from misterhouse (GPL)
 
 =head1 HISTORY
 
 2008-12-09  Initial versions of wg-ow2eib.pl and wg-eiblis.pl
 see SVN
 
 =cut
