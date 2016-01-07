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

        _weather_html => "/var/www/default/htdocs/weather/wunderground_weather_plugin.html",          # Ausgabe als HTML

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

        my $html = "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>";
        $html = $html . "<html>";
        $html = $html . "  <head>\n";
        $html = $html . "    <title>Wetter</title>\n";
        $html = $html . "    <meta name='language' content='de'>\n";
        $html = $html . "    <meta http-equiv='content-type' content='text/html; charset=utf8'>\n";
        $html = $html . "    <link href='wunderground_weather.css' rel='stylesheet' type='text/css' />\n";
        $html = $html . "  </head>\n";
        $html = $html . "  <body>\n";

        $html = $html . "    <table background=\"".$self->{_symbolebg}.$icontoday."\.png\">\n";
        $html = $html . "      <tr height=200px>\n";
        $html = $html . "        <td align=center width=150x >\n";
        $html = $html . "          <strong>Aktuell</strong>\n";
        $html = $html . "          <h3>".$weather->{current_observation}->{weather}."</h3>\n";
        $html = $html . "          <h3><font color=\"FFF799\">".$weather->{current_observation}->{temp_c}." &degC</font></h3>\n";
        $html = $html . "          Gef&uuml;hlt:&nbsp;".$weather->{current_observation}->{feelslike_c}."&degC<br/>\n";
        $html = $html . "          <img width=100px height=100px src=\"".$self->{_symbole}.$weather->{current_observation}->{icon}."\.png\" />\n";
        $html = $html . "        </td>\n";

        for(my $j=1;$j<4;$j++) {
            my $forecast = $weather->{forecast}->{simpleforecast}->{forecastdays}->{forecastday}->[$j];
            $html = $html . "    <td align=center width=150px >\n";
            $html = $html . "      <strong>".$forecast->{date}->{weekday}."</strong>\n";
            $html = $html . "      <h3>".$forecast->{conditions}."</h3>\n";
            $html = $html . "      <h3><font color=\"FFF799\">".$forecast->{low}->{celsius}." &degC bis \n".$forecast->{high}->{celsius}." &degC</h3></font>\n";
            $html = $html . "      Regen ".$forecast->{pop}."%\n</h3>";
            $html = $html . "      <img width=100px height=100px src=\"".$self->{_symbole}.$forecast->{icon}."\.png\" alt=\"".$forecast->{conditions}."\" />\n";
            $html = $html . "</td>\n";
        }
        $html = $html . "      </tr>\n";
        $html = $html . "    </table>\n";
        $html = $html . "  </body>\n";
        $html = $html . "</html>\n";

        my $html_datei = $self->{_weather_html};

        open(HTML, ">:utf8", $html_datei);    # HTML Datei zum Schreiben
        print HTML $html;
        close(HTML);
        $self->{_lastRun} = time();   
    }
}


1;
