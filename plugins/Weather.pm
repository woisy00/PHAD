package plugins::Weather;

=pod

=head1 NAME

Weather - My author was too lazy to write an abstract

=head1 SYNOPSIS

  my $object = Weather->new(
      foo  => 'bar',
      flag => 1,
  );
  
  $object->dummy;

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

=cut

use strict;
use warnings;

use LWP::Simple;
use XML::Simple;
use Data::Dumper;
use Encode qw(encode decode);
use Time::HiRes qw ( time gettimeofday );
use PHAD::Logger;
use PHAD::Daemon;


sub new {
    my $class = shift;
    my ($phad) = @_;
    
    my $self = bless { 
        _phad => $phad,
        _lastRun => undef,
        
        _logger => PHAD::Logger->new(1),

        _provider => "Wunderground",     # Anbieter, derzeit unterstuetzt: Wunderground
        _city => "Ihrlerstein",          # Meine Stadt, hier statt &uuml;,&auml;,&ouml; einfach u,a,o nehmen oder ue,ae,oe
        _country => "Germany",           # Mein Land
        _lang => "DL",                   # Meine Sprache (DL = deutsch)
        _api => "d553bb83e0e29d01",      # API, muss man sich bei Wunderground besorgen

        _cycle => 5,               # 5 seconds...

        _weather_html => "/var/www/default/html/weather/wunderground_weather_plugin.html",          # Ausgabe als HTML

        _wunderground_ip => "http://api.wunderground.com/api/",
        _symbole         => "iconset6/",                          # Pfad zu den Wettersymbolen
        _symbolebg       => "symbolebg/",                 # Pfad zu den Wetterhintergr
        _wunderground_css => "wunderground_weather.css",           # Das Stylesheet
    }, $class;
    return $self;
}


sub run_PHAD_plugin {
    my ($self) = @_;
    
    if (!$self->{_lastRun} || time() - $self->{_lastRun} > $self->{_cycle}) {
        $self->{_logger}->debug("Updating weather information.");
        my $url = $self->{_wunderground_ip}.$self->{_api}."/conditions/forecast/astronomy/lang:".$self->{_lang}."/q/".$self->{_country}."\/".$self->{_city}."\.xml";
        my $xml = get($url);
        $self->{_logger}->warn("Couldn't get it!") unless defined $xml;
        $self->{_logger}->debug("Fetched: ".$xml) if defined $xml;
        my $weather = XMLin($xml, suppressempty => '');

        my $length = -4;
        my $icontoday = substr ($weather->{current_observation}->{icon_url}, 31, $length);

        my $html = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
        <html>
                <head>
                        <title>Wetter</title>
                        <meta name='language' content='de'>
                        <meta http-equiv='content-type' content='text/html; charset=utf8'>
                        <link href='wunderground_weather.css' rel='stylesheet' type='text/css' />
                </head>
                <body>

                <table background=\"".$self->{_symbolebg}.$icontoday."\.png\">".
                        "<tr height=200px>\n".
                                "<td align=center width=150x >\n".
                                        "<strong>Aktuell</strong>\n".
                                        "<h3>".$weather->{current_observation}->{weather}."</h3>\n".
                                        "<h3><font color=\"FFF799\">".$weather->{current_observation}->{temp_c}." &degC</font></h3>\n".
                                        "Gef&uuml;hlt:&nbsp;".$weather->{current_observation}->{feelslike_c}."&degC<br/>\n".
                                        "<img width=100px height=100px src=\"".$self->{_symbole}.$weather->{current_observation}->{icon}."\.png\" alt\"".$weather->{current_observation}->{conditions}."\" />\n".
                                "</td>\n";

                        for(my $j=1;$j<4;$j++) {
                        $html = $html.
                        "<td align=center width=150px >\n".
                                "<strong>".$weather->{forecast}->{simpleforecast}->{forecastdays}->{forecastday}->[$j]->{date}->{weekday}."</strong>\n".
                                "<h3>".$weather->{forecast}->{simpleforecast}->{forecastdays}->{forecastday}->[$j]->{conditions}."</h3>\n".
                                "<h3><font color=\"FFF799\">".$weather->{forecast}->{simpleforecast}->{forecastdays}->{forecastday}->[$j]->{low}->{celsius}." &degC bis \n".$weather->{forecast}->{simpleforecast}->{forecastdays}->{forecastday}->[$j]->{high}->{celsius}." &degC</h3></font>\n".
                                "Regen ".$weather->{forecast}->{simpleforecast}->{forecastdays}->{forecastday}->[$j]->{pop}."%\n</h3>".
                                "<img width=100px height=100px src=\"".$self->{_symbole}.$weather->{forecast}->{simpleforecast}->{forecastdays}->{forecastday}->[$j]->{icon}."\.png\" alt=\"".
                                        $weather->{forecast}->{simpleforecast}->{forecastdays}->{forecastday}->[$j]->{conditions}."\" />\n".
                                "</td>\n";
                        }
                        $html = $html."</tr>
                </table>
                </body>
        </html>";


        my $html_datei = $self->{_weather_html};

        open(HTML, ">:utf8", $html_datei);    # HTML Datei zum Schreiben
        print HTML $html;
        close(HTML);
        $self->{_lastRun} = time();   
    }
}


1;
