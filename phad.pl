#!/usr/bin/perl -w
# Perl Home Automation Daemon
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA

use strict;

use FindBin;
use lib "$FindBin::Bin/lib";  # Add /home/foo/bin/lib to search path

use Getopt::Std;
getopts("dc:", \my %opts);

use PHAD::Daemon;
use PHAD::Logger;
use PHAD::Config;

my $logger = PHAD::Logger->new($opts{d});

# Options
while ((my $key, my $value) = each %opts) {
    $logger->debug("opt $key = $value");
}

# Config files
# global
my $config;
if ($opts{c}) {
    $logger->info("Config-File is: $opts{c}");
    $config = $opts{c};
} else {
    $config = "/etc/phad/phad.conf" 
}

$logger->info("Started with PID: $$ \n");

my $phad = PHAD::Daemon->new($config, $opts{d});

$phad->mainLoop();