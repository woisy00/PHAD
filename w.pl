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

use CGI;
use PHAD::Device;
use PHAD::DPT;

use RPC::Lite::Client;

my $q = CGI->new;


# Process an HTTP request
my $session          = $q->param('s');    
my $device_address   = $q->param('a');
my $value            = $q->param('v');
my $timestamp        = $q->param('ts');


my $client = RPC::Lite::Client->new({
            Transport  => 'TCP:Host=localhost,Port=10000',
            Serializer => 'JSON', # JSON is actually the default,
                                    # this argument is unnecessary
        });
$client->Request('setValue', $device_address, $value);        

# Prepare various HTTP responses
print $q->header();
print $q->header('application/json');

print '{"success":"1"}\n';