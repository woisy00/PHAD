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
    }, $class;
    return $self;
}


sub decode_dpt2 { #2bit "signed bit"
    my $val=hex(shift) & 0x03;
    return $val > 1 ? $val-4 : $val;
}

sub decode_dpt3 { #4bit signed integer
    my $val=hex(shift) & 0x0f;
    return $val > 7 ? 8-$val : $val;
}

sub decode_dpt4 { #1byte char
    return sprintf("%c", hex(shift));
}

sub decode_dpt5 { #1byte unsigned percent
    return sprintf("%.1f", hex(shift) * 100 / 255);
}

sub decode_dpt510 { #1byte unsigned UChar
    return hex(shift);
}

sub decode_dpt6 { #1byte signed
    my $val = hex(shift);
    return $val > 127 ? $val-256 : $val;
}

sub decode_dpt7 { #2byte unsigned
    my @val = split(" ",shift);
    return (hex($val[0])<<8) + hex($val[1]);
}

sub decode_dpt8 { #2byte signed
    my @val = split(" ",shift);
    my $val2 = (hex($val[0])<<8) + hex($val[1]);
    return $val2 > 32767 ? $val2-65536 : $val2;
}

sub decode_dpt9 {# encode DPT9.001/EIS 5
    my @data = @_;
    my $res;
    
    unless ($#data == 2) {
        ($data[1],$data[2]) = split(' ',$data[0]);
        $data[1] = hex $data[1];
        $data[2] = hex $data[2];
        unless (defined $data[2]) {
            return;
        }
    }
    my $sign = $data[1] & 0x80;
    my $exp = ($data[1] & 0x78) >> 3;
    my $mant = (($data[1] & 0x7) << 8) | $data[2];
    
    $mant = -(~($mant - 1) & 0x7ff) if $sign != 0;
    $res = (1 << $exp) * 0.01 * $mant;
    return $res;
}

sub decode_dpt10 { #3byte time
    my @val = split(" ",shift);
    my @wd = qw(Null Mo Di Mi Do Fr Sa So);
    $val[0] = hex($val[0]);
    $val[1] = hex($val[1]);
    $val[2] = hex($val[2]);
    unless ($val[2]) { return; }
    my $day = ($val[0] & 0xE0) >> 5;
    my $hour    = $val[0] & 0x1F;
    my $minute  = $val[1];
    my $second  = $val[2];
    return sprintf("%s %02i:%02i:%02i",$wd[$day],$hour,$minute,$second);
}

sub decode_dpt11 { #3byte date
    my @val = split(" ",shift);
    my @wd = qw(Null Mo Di Mi Do Fr Sa So);
    $val[0] = hex($val[0]);
    $val[1] = hex($val[1]);
    $val[2] = hex($val[2]);
    unless ($val[2]) { return; }
    my $mday    = $val[0] & 0x1F;
    my $mon     = $val[1] & 0x0F;
    my $year    = $val[2] & 0x7F;
    $year = $year < 90 ? $year+2000 : $year+1900; # 1990 - 2089
    return sprintf("%04i-%02i-%02i",$year,$mon,$mday);
}

sub decode_dpt12 { #4byte unsigned
    my @val = split(" ",shift);
    return (hex($val[0])<<24) + (hex($val[1])<<16) + (hex($val[2])<<8) + hex($val[3]);
}

sub decode_dpt13 { #4byte signed
    my @val = split(" ",shift);
    my $val2 = (hex($val[0])<<24) + (hex($val[1])<<16) + (hex($val[2])<<8) + hex($val[3]);
    return $val2 >  2147483647 ? $val2-4294967296 : $val2;
}

sub decode_dpt14 { #4byte float
    #Perls unpack for float is somehow strange broken
    my @val = split(" ",shift);
    my $val2 = (hex($val[0])<<24) + (hex($val[1])<<16) + (hex($val[2])<<8) + hex($val[3]);
    my $sign = ($val2 & 0x80000000) ? -1 : 1;
    my $expo = (($val2 & 0x7F800000) >> 23) - 127;
    my $mant = ($val2 & 0x007FFFFF | 0x00800000);
    my $num = $sign * (2 ** $expo) * ( $mant / (1 << 23));
    return sprintf("%.4f",$num);
}

sub decode_dpt16 { # 14byte char
    my @val = split(" ",shift);
    my $chars;
    for (my $i=0;$i<14;$i++) {
        $chars .= sprintf("%c", hex($val[$i]));
    }
    return sprintf("%s",$chars);
}

sub decode {
    my $self = shift;
    my $data = shift;
    my $value = undef;
    $data =~ s/\s+$//g;
    given ($self->{_dptid}) {
        when (/^10/)      { $value = decode_dpt10($data); }
        when (/^11/)      { $value = decode_dpt11($data); }
        when (/^12/)      { $value = decode_dpt12($data); }
        when (/^13/)      { $value = decode_dpt13($data); }
        when (/^14/)      { $value = decode_dpt14($data); }
        when (/^16/)      { $value = decode_dpt16($data); }
        when (/^17/)      { $value = decode_dpt510($data & 0x3F); }
        when (/^20/)      { $value = decode_dpt510($data); }
        when (/^\d\d/)    { return; } # other DPT XX 15 are unhandled
        when (/^1/)       { $value = int($data); }
        when (/^2/)       { $value = decode_dpt2($data); }
        when (/^3/)       { $value = decode_dpt3($data); }
        when (/^4/)       { $value = decode_dpt4($data); }
        when ([5,'5.001'])  { $value = decode_dpt5($data); }
        when (['5.004','5.005','5.010']) { $value = decode_dpt510($data); }
        when (/^6/) { $value = decode_dpt6($data); }
        when (/^7/) { $value = decode_dpt7($data); }
        when (/^8/) { $value = decode_dpt8($data); }
        when (/^9/) { $value = decode_dpt9($data); }
        default   { return; } # nothing
    }
    return $value;
}


sub encode_dpt9 { # 2byte signed float
    my $state = shift;
    my $data;
    
    my $sign = ($state <0 ? 0x8000 : 0);
    my $exp  = 0;
    my $mant = 0;
    
    $mant = int($state * 100.0);
    while (abs($mant) > 2047) {
        $mant /= 2;
        $exp++;
    }
    $data = $sign | ($exp << 11) | ($mant & 0x07ff);
    return $data >> 8, $data & 0xff;
}

sub encode_dpt5 {
    my $value = shift;
    $value = 100 if ($value > 100);
    $value = 0 if ($value < 0);;
    my $byte = sprintf ("%.0f", $value * 255 / 100);
    return($byte);
}


sub encode {
    my $self = shift;
    my $value = shift;
    #,$dpt,$response,$dbgmsg) = @_;
    my $bytes;
    my $apci = 0x80; # 0x40=response, 0x80=write, 0x00=non-blocking read

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
    given ($self->{_dptid}) {
        when (/^10/) {
            my %wd=(Mo=>1, Di=>2, Mi=>3, Do=>4, Fr=>5, Sa=>6, So=>7, Mon=>1, Tue=>2, Wed=>3, Thu=>4, Fri=>5, Sat=>6, Sun=>7);
            my $wdpat=join('|',keys %wd);
            my ($w,$h,$m,$s);
            return unless ($w,$h,$m,$s)=($value=~/^($wdpat)?\s*([0-2][0-9])\:([0-5][0-9])\:?([0-5][0-9])?\s*/si);
            return unless defined $h && defined $m;
            $w=$wd{$w} if defined $wd{$w};
            $h+=($w<<5) if $w;
            $s=0 unless $s;
            $bytes=pack("CCCCC",0,$apci,$h,$m,$s);
        }
        when (/^11/) {
            my ($y,$m,$d);
            return unless ($y,$m,$d)=($value=~/^([1-2][0-9][0-9][0-9])\-([0-1][0-9])\-([0-3][0-9])\s*/si);
            return if $y<1990 || $y>=2090;
            $y%=100;
            $bytes=pack("CCCCC",0,$apci,$d,$m,$y);
        }
        when (/^12/)             { $bytes = pack ("CCL>", 0, $apci, $value); }  #EIS11.000/DPT12 (4 byte unsigned)
        when (/^13/)             { $bytes = pack ("CCl>", 0, $apci, $value); }
        when (/^14/)             { $bytes = pack ("CCf>", 0, $apci, $value); }
        when (/^16/)             { $bytes = pack ("CCa14", 0, $apci, $value); }
        when (/^17/)             { $bytes = pack ("CCC", 0, $apci, $value & 0x3F); }
        when (/^20/)             { $bytes = pack ("CCC", 0, $apci, $value); }
        when (/^\d\d/)           { return; } # other DPT XX 15 are unhandled
        when (/^[1,2,3]/)        { $bytes = pack ("CC", 0, $apci | ($value & 0x3f)); } #send 6bit small
        when (/^4/)              { $bytes = pack ("CCc", 0, $apci, ord($value)); }
        when ([5,5.001])         { $bytes = pack ("CCC", 0, $apci, encode_dpt5($value)); } #EIS 6/DPT5.001 1byte
        when ([5.004,5.005,5.010]) { $bytes = pack ("CCC", 0, $apci, $value); }
        when (/^5/)              { $bytes = pack ("CCC", 0, $apci, $value); }
        when (/^6/)              { $bytes = pack ("CCc", 0, $apci, $value); }
        when (/^7/)              { $bytes = pack ("CCS>", 0, $apci, $value); }
        when (/^8/)              { $bytes = pack ("CCs>", 0, $apci, $value); }
        when (/^9/)              { $bytes = pack ("CCCC", 0, $apci, encode_dpt9($value)); } #EIS5/DPT9 2byte float
        default                  { $self->{_logger}->warn("None or unsupported DPT: $self->{_dptid} value $value"); return; }
    }
    return $bytes;
}

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
