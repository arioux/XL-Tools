#!/usr/bin/perl
# Perl - v: 5.16.3
#------------------------------------------------------------------------------#
# XL-ToolsUtils.pl  : Util functions for XL-Tools
# WebSite				    : http://le-tools.com/XL-Tools.html
# CodePlex			    : https://xltools2.codeplex.com
# GitHub				    : https://github.com/arioux/XL-Tools
# Documentation	    : http://le-tools.com/XL-ToolsDoc.html
# Creation          : 2015-12-21
# Modified          : 2017-07-02
# Author            : Alain Rioux (admin@le-tools.com)
#
# Copyright (C) 2015-2017  Alain Rioux (le-tools.com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Modules
#------------------------------------------------------------------------------#
use strict;
use warnings;
use DBI;
use Net::DNS;
use base qw/Net::DNS::Resolver::Base/;
use Net::CIDR 'cidr2range';
use Net::IPv6Addr;
use NetAddr::IP;
use Regexp::IPv6 qw($IPv6_re);
use Geo::IP;
use Regexp::IPv6 qw($IPv6_re);
use Woothee;
use Parse::HTTP::UserAgent;
use Parse::HTTP::UserAgent::Base::IS;
use Parse::HTTP::UserAgent::Base::Parsers;
use Parse::HTTP::UserAgent::Base::Dumper;
use Parse::HTTP::UserAgent::Base::Accessors;
use HTTP::BrowserDetect;
use HTML::ParseBrowser;
use Business::CreditCard;

#--------------------------#
sub utilsTabFunc
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWinConfig, $refConfig, $CONFIG_FILE, $refWin, $refSTR) = @_;
  my $selFunc = $$refWin->cbUtils->GetCurSel();
  # Possibles value are 0 = 'NSLookup', 1 = 'CIDR to IP Range', 2 = 'IP Range to CIDR', 3 = 'CIDR to IP list',
  # 4 = 'IP to Arpa', 5 = 'Arpa to IP', 6 = 'Resolve MAC Address', 7 = 'Resolve IPv4 GeoIP', 8 = 'Resolve ISP',
  # 9 = 'Resolve User-agent', 10 = 'Credit Card to issuing company', 11 = 'Address to GPS coordinates',
  # 12 = 'Distance between locations', 13 = 'Custom functions'
  
  # Merge lists (except time difference)
  push(@{$refList1}, @{$refList2}) if $selFunc != 12;
  my $noResultOpt = $$refWinConfig->rbNoResultOpt2->Checked();
  my $nbrItems    = scalar(@{$refList1});
  my $curr = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # 0 = 'NSLookup'
  if ($selFunc == 0) {
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        my $newItem = &nsLookup($item, $refConfig);
        if ($newItem) { push(@items, $newItem); }
        else {
          if ($noResultOpt) { push(@items, $$refSTR{'noMatch'}); }
          else { push(@items, undef); }
        }
      } else {
        if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
        else { push(@items, undef); }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 1 = 'CIDR to IP Range'
  elsif ($selFunc == 1) {
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        my $newItem;
        # Ex. IPv4: 123.123/16 to 123.123.0.0 - 123.123.255.255
        if ($item =~ /((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){0,3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/[0-9]{1,2})/) {
          my($refIp, $mask) = split(/\//, $item);
          my($start, $end) = split(/\-/, (Net::CIDR::cidr2range($item))[0]);
          while ($start !~ /(?:[0-9]{1,3}\.){3}[0-9]{1,3}/) { $start .= '.0';   }
          while ($end   !~ /(?:[0-9]{1,3}\.){3}[0-9]{1,3}/) { $end   .= '.255'; }
          $newItem = "$start - $end" if $start and $end;
        # Ex. IPv6: 2001:db8:1234::/48 to 2001:db8:1234:0000:0000:0000:0000:0000 - 2001:db8:1234:ffff:ffff:ffff:ffff:ffff
        } elsif ($item =~ /($IPv6_re\/[0-9]{1,3})/) {
          my($refIp, $mask) = split(/\//, $item);
          my($start, $end) = split(/\-/, (Net::CIDR::cidr2range($item))[0]);
          while ($start =~ /:$/) { chop($start); }
          while ($end   =~ /:$/) { chop($end);   }
          while ($start !~ /(?:[0-9a-fA-F]{1,4}\:){7}[0-9a-fA-F]{1,4}/) { $start .= ':0000'; }
          while ($end   !~ /(?:[0-9a-fA-F]{1,4}\:){7}[0-9a-fA-F]{1,4}/) { $end   .= ':ffff'; }
          $newItem = "$start - $end" if $start and $end;
        }
        if ($newItem) { push(@items, $newItem); }
        else {
          if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
          else { push(@items, undef); }
        }
      } else {
        if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
        else { push(@items, undef); }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 2 = 'IP Range to CIDR'
  elsif ($selFunc == 2) {
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        my $newItem;
        # Ex. IPv4:  123.123.0.0 - 123.123.255.255 (spaces or not) to 123.123/16
        if ($item =~ /((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)) ?\- ?((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))/) {
          my $ipStart = $1;
          my $ipEnd   = $2;
          $newItem = Net::CIDR::range2cidr("$1\-$2");
        # Ex. IPv6: 2001:db8:1234:0000:0000:0000:0000:0000 - 2001:db8:1234:ffff:ffff:ffff:ffff:ffff (spaces or not) to 2001:db8:1234::/48
        } elsif ($item =~ /($IPv6_re) ?\- ?($IPv6_re)/) {
          my $ipStart = $1;
          my $ipEnd   = $2;
          $newItem = Net::CIDR::range2cidr("$1\-$2");
        }
        if ($newItem) { push(@items, $newItem); }
        else {
          if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
          else { push(@items, undef); }
        }
      } else {
        if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
        else { push(@items, undef); }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 3 = 'CIDR to IP list'
  elsif ($selFunc == 3) {
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        my $newItem;
        # Ex. IPv4: 123.123/28
        if ($item =~ /(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){0,3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\/[0-9]{1,2}/) {
          if (my $n = NetAddr::IP->new_no($item)) {
            for my $ip ( @{$n->hostenumref} ) { $newItem .= $ip->addr."\r\n"; }
            chop($newItem); chop($newItem);
          }
        # Ex. IPv6: 2001:db8:1234::/120
        } elsif ($item =~ /$IPv6_re\/[0-9]{1,3}/) {
          if (my $n = NetAddr::IP->new6($item)) {
            for my $ip ( @{$n->hostenumref} ) { $newItem .= $ip->addr."\r\n"; }
            chop($newItem); chop($newItem);
          }
        }
        if ($newItem) { push(@items, $newItem); }
        else {
          if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
          else { push(@items, undef); }
        }
      } else {
        if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
        else { push(@items, undef); }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 4 = 'IP to Arpa'
  elsif ($selFunc == 4) {
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        my $newItem;
        # IPv4
        # 192.168.1.100 to 100.1.168.192.in-addr.arpa
        if ($item =~ /(?:[^0-9]|^)((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))(?:[^0-9\.]|$)/) {
          $newItem = join('.',reverse(split(/\./,$1))) . '.in-addr.arpa';
        # IPv6
        # 2001:610:240:22::c100:68b to b.8.6.0.0.0.1.c.0.0.0.0.0.0.0.0.2.2.0.0.0.4.2.0.0.1.6.0.1.0.0.2.ip6.arpa
        } elsif ($item =~ /($IPv6_re)/) {
          my $IPv6 = new Net::IPv6Addr($1);
          $newItem = $IPv6->to_string_ip6_int();
          $newItem =~ s/.IP6.INT./.ip6.arpa/;
        }
        if ($newItem) { push(@items, $newItem); }
        else {
          if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
          else { push(@items, undef); }
        }
      } else {
        if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
        else { push(@items, undef); }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 5 = 'Arpa to IP'
  elsif ($selFunc == 5) {
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        my $newItem;
        # IPv4
        # 100.1.168.192.in-addr.arpa to 192.168.1.100
        if ($item =~ /((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)).in-addr.arpa/) {
          $newItem = join('.', reverse(split(/\./, $1)));
        # IPv6
        # b.8.6.0.0.0.1.c.0.0.0.0.0.0.0.0.2.2.0.0.0.4.2.0.0.1.6.0.1.0.0.2.ip6.arpa to 2001:610:240:22::c100:68b
        } elsif ($item =~ /((?:[0-9a-fA-F]\.){32})ip6\.arpa/) {
          my $IPv6Arpa = $1; # b.8.6.0.0.0.1.c.0.0.0.0.0.0.0.0.2.2.0.0.0.4.2.0.0.1.6.0.1.0.0.2.
          $IPv6Arpa    =~ s/\.//g;
          my @parts    = reverse(split("", $IPv6Arpa));
          my $IPv6Long;
          while (my @next_p = splice @parts, 0, 4) {
            $IPv6Long .= join('',@next_p);
            $IPv6Long .= ':';
          }
          chop($IPv6Long);
          my $IPv6 = new Net::IPv6Addr($IPv6Long);
          $newItem = $IPv6->to_string_compressed();
        }
        if ($newItem) { push(@items, $newItem); }
        else {
          if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
          else { push(@items, undef); }
        }
      } else {
        if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
        else { push(@items, undef); }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 6 = 'Resolve MAC Address'
  elsif ($selFunc == 6) {
    my $MACOUIDB = $$refWinConfig->tfMACOUIDB->Text();
    if (-f $MACOUIDB) {
      # Load MACOUI database
      my $dsn = "DBI:SQLite:dbname=$MACOUIDB";
      if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
        my $sth = $dbh->prepare("SELECT org FROM MACOUI WHERE prefix == ?");
        foreach my $item (@{$refList1}) {
          $item =~ s/[\r\n]//g;  # Remove any line break
          if ($item) {
            my $newItem;
            if ($item =~ /((?:[a-fA-F0-9]{2}[\:\-]?){2}[a-fA-F0-9]{2})[\-\:]?(?:[a-fA-F0-9]{2}[\:\-]?){2}[a-fA-F0-9]{2}/) {
              my $prefix =  $1;
              $prefix    =~ s/[\:\-]//g;
              $prefix    =~ tr/a-f/A-F/;
              my $rv  = $sth->execute($prefix);
              if ($rv >= 0) {
                my @fields = $sth->fetchrow_array();
                $newItem = join('',@fields) if scalar(@fields) > 0;
              }
              if ($newItem) { push(@items, $newItem); }
              else {
                if ($noResultOpt) { push(@items, $$refSTR{'noMatch'}); }
                else { push(@items, undef); }
              }
            } else {
              if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
              else { push(@items, undef); }
            }
          } else {
            if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
            else { push(@items, undef); }
          }
          # Progress
          $curr++;
          $$refWin->lblPbCount->Text("$curr / $nbrItems");
          $$refWin->pb->StepIt();
        }
        $sth->finish();
        $dbh->disconnect();
      } else { Win32::GUI::MessageBox($$refWin, $$refSTR{'errorConnectDB'}, $$refSTR{'error'}, 0x40010); }
    } else { Win32::GUI::MessageBox($$refWin, 'MACOUI '.$$refSTR{'DBnotFound'}.'...', $$refSTR{'error'}, 0x40010); }
  }
  # 7 = 'Resolve IPv4 GeoIP'
  elsif ($selFunc == 7) {
    my $geoIPDB = $$refWinConfig->tfGeoIPDB->Text();
    my $gi      = Geo::IP->open($geoIPDB, GEOIP_MEMORY_CACHE);
    # Add headers
    if ($$refWin->chAddHeaders->Checked()) {
      my $headers;
      $headers .= $$refSTR{'country'}     . "\t" if $$refWin->chGeoIPOpt2->Checked();
      $headers .= $$refSTR{'countryCode'} . "\t" if $$refWin->chGeoIPOpt3->Checked();
      $headers .= $$refSTR{'region'}      . "\t" if $$refWin->chGeoIPOpt4->Checked();
      $headers .= $$refSTR{'regionCode'}  . "\t" if $$refWin->chGeoIPOpt5->Checked();
      $headers .= $$refSTR{'city'}        . "\t" if $$refWin->chGeoIPOpt6->Checked();
      $headers .= $$refSTR{'postalCode'}  . "\t" if $$refWin->chGeoIPOpt7->Checked();
      $headers .= $$refSTR{'GPScoord'}    . "\t" if $$refWin->chGeoIPOpt8->Checked();
      $headers .= $$refSTR{'tzName'}      . "\t" if $$refWin->chGeoIPOpt9->Checked();
      $headers .= $$refSTR{'tzOffset'}    . "\t" if $$refWin->chGeoIPOpt10->Checked();
      chop($headers);
      push(@items, $headers);
    }
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        my $newItem;
        # IPv4 only
        if ($item =~ /(?:[^0-9]|^)((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))(?:[^0-9\.]|$)/) {
          if (my $record = $gi->record_by_addr($1)) {
            if ($$refWin->chGeoIPOpt2->Checked()) { if ($record->country_name) { $newItem .= $record->country_name . "\t" ; } else { $newItem .= "\t"; } }
            if ($$refWin->chGeoIPOpt3->Checked()) { if ($record->country_code) { $newItem .= $record->country_code . "\t" ; } else { $newItem .= "\t"; } }
            if ($$refWin->chGeoIPOpt4->Checked()) { if ($record->region_name ) { $newItem .= $record->region_name  . "\t" ; } else { $newItem .= "\t"; } }
            if ($$refWin->chGeoIPOpt5->Checked()) { if ($record->region      ) { $newItem .= $record->region       . "\t" ; } else { $newItem .= "\t"; } }
            if ($$refWin->chGeoIPOpt6->Checked()) { if ($record->city        ) { $newItem .= $record->city         . "\t" ; } else { $newItem .= "\t"; } }
            if ($$refWin->chGeoIPOpt7->Checked()) { if ($record->postal_code ) { $newItem .= $record->postal_code  . "\t" ; } else { $newItem .= "\t"; } }
            if ($$refWin->chGeoIPOpt8->Checked()) {
              if ($record->latitude and $record->longitude) { $newItem .= $record->latitude.", ".$record->longitude . "\t" ; }
              else { $newItem .= "\t"; }
            }
            if ($$refWin->chGeoIPOpt9->Checked()) { if ($record->time_zone  ) { $newItem .= $record->time_zone     . "\t" ; } else { $newItem .= "\t"; } }
            if ($$refWin->chGeoIPOpt10->Checked()) {
              if ($record->time_zone and my $tz = DateTime::TimeZone->new(name => $record->time_zone)) {
                my $TZOffset;
                if ($tz->{last_offset}) {
                  $TZOffset = sprintf("%+05d", $tz->{last_offset}/36); 
                  $newItem .= $TZOffset . "\t";
                } else { $newItem .= "\t"; }
              } else { $newItem .= "\t"; }
            }
            chop($newItem);
          }
          if ($newItem) { push(@items, $newItem); }
          else {
            if ($noResultOpt) { push(@items, $$refSTR{'noMatch'}); }
            else { push(@items, undef); }
          }
        } else {
          if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
          else { push(@items, undef); }
        }
      } else {
        if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
        else { push(@items, undef); }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 8 = 'Resolve ISP'
  elsif ($selFunc == 8) {
    my $XLWHOISDBFile = $$refWinConfig->tfXLWHOISDB->Text();
    if (-f $XLWHOISDBFile) {
      # Load XL-Whois database
      my $dsn = "DBI:SQLite:dbname=$XLWHOISDBFile";
      if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
        foreach my $item (@{$refList1}) {
          $item =~ s/[\r\n]//g;  # Remove any line break
          if ($item) {
            my $newItem;
            if ($item =~ /(?:[^0-9]|^)((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))(?:[^0-9\.]|$)/ or $item =~ /($IPv6_re)/) {
              my $ip = $1;
              if    ($item =~ /\./) { $newItem = &checkIP_WhoisDB_IPv4($ip, \$dbh, $refWin, $refSTR); } # IPv4
              elsif ($item =~ /\:/) { $newItem = &checkIP_WhoisDB_IPv6($ip, \$dbh);                   } # IPv6
              if ($newItem) { push(@items, $newItem); }
              else {
                if ($noResultOpt) { push(@items, $$refSTR{'noMatch'}); }
                else { push(@items, undef); }
              }
            } else {
              if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
              else { push(@items, undef); }
            }
          } else {
            if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
            else { push(@items, undef); }
          }
          # Progress
          $curr++;
          $$refWin->lblPbCount->Text("$curr / $nbrItems");
          $$refWin->pb->StepIt();
        }
        $dbh->disconnect();
      } else { Win32::GUI::MessageBox($$refWin, $$refSTR{'errorConnectDB'}, $$refSTR{'error'}, 0x40010); }
    } else { Win32::GUI::MessageBox($$refWin, 'XL-Whois '.$$refSTR{'DBnotFound'}.'...', $$refSTR{'error'}, 0x40010); }
  }
  # 9 = 'Resolve User-agent'
  elsif ($selFunc == 9) {
    # Add headers
    if ($$refWin->chAddHeaders->Checked()) {
      my $headers;
      $headers .= $$refSTR{'type'}      . "\t" if $$refWin->chUAOpt2->Checked();
      $headers .= $$refSTR{'uaOS'}      . "\t" if $$refWin->chUAOpt3->Checked();
      $headers .= $$refSTR{'uaBrowser'} . "\t" if $$refWin->chUAOpt4->Checked();
      $headers .= $$refSTR{'uaDevice'}  . "\t" if $$refWin->chUAOpt5->Checked();
      $headers .= $$refSTR{'uaLang'}    . "\t" if $$refWin->chUAOpt6->Checked();
      chop($headers);
      push(@items, $headers);
    }
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        my $newItem = &parseUA($item, $refWin);
        if ($newItem) { push(@items, $newItem); }
        else {
          if ($noResultOpt) { push(@items, $$refSTR{'noMatch'}); }
          else { push(@items, undef); }
        }
      } else {
        if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
        else { push(@items, undef); }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 10 = 'Credit Card to issuing company'
  elsif ($selFunc == 10) {
    # Search in local IIN Database
    if ($$refWin->rbIINLocalDB->Checked()) {
      my $IINFile = $$refWinConfig->tfIINDB->Text();
      my %listIIN;
      if (-f $IINFile) {
        # Load IIN database
        my $dsn = "DBI:SQLite:dbname=$IINFile";
        if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
          my $all = $dbh->selectall_arrayref("SELECT * FROM IIN");
          foreach my $row (@$all) {
            my @values = @$row;
            if ($values[0] =~ /(^[0-9]{2})/) { push(@{$listIIN{$1}}, "$values[0]=$values[1]"); }
          }
          $dbh->disconnect();
          foreach my $item (@{$refList1}) {
            $item =~ s/[\r\n]//g;  # Remove any line break
            if ($item) {
              my $newItem;
              # Verify card number some regexs
              if (($item =~ /(?:[^0-9\-]|^)((?:(?:[0-9]{4}\-){3})[0-9]{4})(?:[^0-9\-]|$)/) or # With dashes
                  ($item =~ /(?:[^0-9]|^)((?:(?:[0-9]{4} ){3})[0-9]{4})(?:[^0-9]|$)/     ) or # With spaces
                  ($item =~ /(?:[^0-9\-]|(?:[^b]|^)\-|^)(4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})(?:[^0-9]|$)/) or
                  ($item =~ /(?:[^0-9\-]|(?:[^b]|^)\-|^)(\d{15,18}\d)(?:[^0-9]|$)/)) {
                my $cc   =  $1;
                $cc      =~ s/[\s\-]//g;
                $newItem =  &checkCC_IINDB($cc, \%listIIN);
                if ($newItem) { push(@items, $newItem); }
                else {
                  if ($noResultOpt) { push(@items, $$refSTR{'noMatch'}); }
                  else { push(@items, undef); }
                }
              } else {
                if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
                else { push(@items, undef); }
              }
            } else {
              if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
              else { push(@items, undef); }
            }
            # Progress
            $curr++;
            $$refWin->lblPbCount->Text("$curr / $nbrItems");
            $$refWin->pb->StepIt();
          }
        } else { Win32::GUI::MessageBox($$refWin, $$refSTR{'errorConnectDB'}, $$refSTR{'error'}, 0x40010); }
      } else { Win32::GUI::MessageBox($$refWin, 'IIN '.$$refSTR{'DBnotFound'}.'...', $$refSTR{'error'}, 0x40010); }
    # Send queries to www.binlist.net
    } else {
      # Set headers
      my $headers = "$$refSTR{'brand'}\t$$refSTR{'subBrand'}\t$$refSTR{'bank'}\t$$refSTR{'cardType'}\t$$refSTR{'cardCategory'}\t$$refSTR{'countryName'}";
      push(@items, $headers);
      foreach my $item (@{$refList1}) {
        $item =~ s/[\r\n]//g;  # Remove any line break
        if ($item) {
          my $newItem;
          # Verify card number some regexs
          if (($item =~ /(?:[^0-9\-]|^)((?:(?:[0-9]{4}\-){3})[0-9]{4})(?:[^0-9\-]|$)/) or # With dashes
              ($item =~ /(?:[^0-9]|^)((?:(?:[0-9]{4} ){3})[0-9]{4})(?:[^0-9]|$)/     ) or # With spaces
              ($item =~ /(?:[^0-9\-]|(?:[^b]|^)\-|^)(4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})(?:[^0-9]|$)/) or
              ($item =~ /(?:[^0-9\-]|(?:[^b]|^)\-|^)(\d{15,18}\d)(?:[^0-9]|$)/)) {
            my $cc   =  $1;
            $cc      =~ s/[\s\-]//g;
            $newItem =  &checkCC_BinList($cc, $refConfig);
            if ($newItem) { push(@items, $newItem); }
            else {
              if ($noResultOpt) { push(@items, $$refSTR{'noMatch'}); }
              else { push(@items, undef); }
            }
          } else {
            if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
            else { push(@items, undef); }
          }
        } else {
          if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
          else { push(@items, undef); }
        }
        # Progress
        $curr++;
        $$refWin->lblPbCount->Text("$curr / $nbrItems");
        $$refWin->pb->StepIt();
      }
    }
  }
  # 11 = 'Address to GPS coordinates'
  elsif ($selFunc == 11) {
    my $ua = new LWP::UserAgent;
    $ua->agent($$refConfig{'USERAGENT'});
    $ua->default_header('Accept-Language' => 'en');
    my $APIKey = $$refWin->tfAPIKey->Text();
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        $item =~ s/ /+/g; # Replace spaces by + sign
        my $encItem = uri_escape_utf8($item); # Address must be uri encoded
        my $req  = new HTTP::Request GET => "https://maps.googleapis.com/maps/api/geocode/json?address=$encItem&key=$APIKey";
        if (my $json = $ua->request($req)) {
          if (my $d_json = decode_json($json->content)) {
            if (my $lat = $d_json->{results}->[0]->{geometry}->{location}->{lat} and 
                my $lng = $d_json->{results}->[0]->{geometry}->{location}->{lng}) {
              push(@items, "$lat, $lng");
            } else {
              my $msg = $$refSTR{'noMatch'};
              if (my $status = $d_json->{status}) { $msg = $status; }
              if ($noResultOpt) { push(@items, $msg); }
              else { push(@items, undef); }
            }
          } else {
            print $json->content . "- 2\n";
            if ($noResultOpt) { push(@items, $$refSTR{'noMatch'}); }
            else { push(@items, undef); }
          }
        } else {
          if ($noResultOpt) { push(@items, $$refSTR{'errorConnection'}); }
          else { push(@items, undef); }
        }
      } else {
        if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
        else { push(@items, undef); }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 12 = 'Distance between locations'
  elsif ($selFunc == 12) {
    my $loc2;
    # If "Compare to single location" option is checked
    if ($$refWin->chSingleLocation->Checked()) {
      $loc2 = $$refWin->tfSingleLocation->Text();
      push(@{$refList1}, @{$refList2}); # Merge lists
    }
    # Browse location and calculate distance
    foreach my $item (@{$refList1}) {
      $item =~ s/[\r\n]//g;  # Remove any line break
      if ($item) {
        # Gather date in list 2
        if (!$$refWin->chSingleLocation->Checked() and my $item2 = $$refList2[$curr]) {
          $item2 =~ s/[\r\n]//g;  # Remove any line break
          $loc2  = $item2 if $item2;
        }
        # Gather date in list 1 and calculate difference
        if ($loc2 and $item) {
          my ($lat1, $lon1) = split(/, /, $item);
          my ($lat2, $lon2) = split(/, /, $loc2);
          if ($lat1 and $lon1 and $lat2 and $lon2) {
            my $distanceInKM = int(distance($lat1, $lon1 => $lat2, $lon2))/1000;
            push(@items, $distanceInKM);
          } else {
            if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
            else { push(@items, undef); }
          }
        } else {
          if ($noResultOpt) { push(@items, $$refSTR{'invalidInput'}); }
          else { push(@items, undef); }
        }
      }
      # Progress
      $curr++;
      $$refWin->lblPbCount->Text("$curr / $nbrItems");
      $$refWin->pb->StepIt();
    }
  }
  # 13 = 'Custom functions'
  elsif ($selFunc == 13) {
    my $selFuncStr = $$refWin->cbCFLists->GetString($$refWin->cbCFLists->GetCurSel());
    my ($title, $dbFile);
    # Gather path to database
    if ($selFuncStr and $selFuncStr ne $$refSTR{'cbCFLists'}.'...') {
      my $j = 1;
      while (exists($$refConfig{'CF'.$j})) {
        my $selFuncStrQuoted = quotemeta($selFuncStr);
        if ($$refConfig{'CF'.$j} =~ /$selFuncStrQuoted\|/) {
          ($title, $dbFile) = split(/\|/, $$refConfig{'CF'.$j});
          &saveConfig($refConfig, $CONFIG_FILE);
          last;
        }
        $j++;
      }
      if (-f $dbFile) {
        # Load CF database
        my $dsn = "DBI:SQLite:dbname=$dbFile";
        if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
          my $sth;
          # Match case ?
          if ($$refWin->chCFMatchCase->Checked()) { $sth = $dbh->prepare("SELECT value FROM DATA WHERE key == ?");                }
          else                                    { $sth = $dbh->prepare("SELECT value FROM DATA WHERE key == ? COLLATE NOCASE"); }
          foreach my $item (@{$refList1}) {
            $item =~ s/[\r\n]//g;  # Remove any line break
            if ($item) {
              my $newItem;
              my $rv  = $sth->execute($item);
              if ($rv >= 0) {
                my @fields = $sth->fetchrow_array();
                $newItem = join('',@fields) if scalar(@fields) > 0;
              }
              if ($newItem) { push(@items, $newItem); }
              else {
                if ($noResultOpt) { push(@items, $$refSTR{'noMatch'}); }
                else { push(@items, undef); }
              }
            } else {
              if ($noResultOpt) { push(@items, $$refSTR{'noInput'}); }
              else { push(@items, undef); }
            }
            # Progress
            $curr++;
            $$refWin->lblPbCount->Text("$curr / $nbrItems");
            $$refWin->pb->StepIt();
          }
          $sth->finish();
          $dbh->disconnect();
        } else { Win32::GUI::MessageBox($$refWin, $$refSTR{'errorConnectDB'}, $$refSTR{'error'}, 0x40010); }
      } else { Win32::GUI::MessageBox($$refWin, $$refSTR{'selectedCF'}.' '.$$refSTR{'DBnotFound'}.'...', $$refSTR{'error'}, 0x40010); }
    }
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= $_ if $_; $itemsRes .= "\r\n"; }
  return(\$itemsRes);
  
}  #--- End utilsTabFunc

#--------------------------#
sub nsLookup
#--------------------------#
{
  # Local variables
  my ($item, $refConfig) = shift;
  # $item is an IP address
  if ($item =~ /(?:[^0-9]|^)((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))(?:[^0-9\.]|$)/ or
      $item =~ /($IPv6_re)/) {
    my $res = Net::DNS::Resolver->new;
    $res->tcp_timeout($$refConfig{'NSLOOKUP_TIMEOUT'});
    $res->udp_timeout($$refConfig{'NSLOOKUP_TIMEOUT'});
    my $packet = $res->query($1, "PTR", "IN");
    if ($packet) {
      my @addrs  = $packet->answer;
      my $hostname = '';
      foreach (@addrs) { $hostname .= $_->ptrdname.", " if $_->type eq 'PTR' and $_->ptrdname; }
      if ($hostname) {
        chop($hostname); chop($hostname);
        return($hostname);
      }
    }
  }
  # $item is a hostname or domain name
  elsif ($item =~ /((?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.){2,}[a-zA-Z]{2,})(?:[^a-zA-Z]|$)/ or # Hostname
         $item =~ /((?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,})(?:[^\w\.\-]|$)/) {    # Domain name
    my $res = Net::DNS::Resolver->new;
    $res->tcp_timeout($$refConfig{'NSLOOKUP_TIMEOUT'});
    $res->udp_timeout($$refConfig{'NSLOOKUP_TIMEOUT'});
    my $packet = $res->query($1);
    if ($packet) {
      my @addrs = $packet->answer;
      my $addr  = '';
      foreach (@addrs) { $addr .= $_->address.", " if ($_->type eq 'A' or $_->type eq 'AAAA') and $_->address; }
      if ($addr) {
        chop($addr); chop($addr);
        return($addr);
      }
    }
  }
  
}  # Fin nsLookup

#--------------------------#
sub parseUA
#--------------------------#
{
  # Local variables
  my ($uaStr, $refWin) = @_;
  my $UAInfos;
  # Parse User-Agent String
  my $refUA = Woothee->parse($uaStr); # Ex.: {'name'=>"Internet Explorer", 'category'=>"pc", 'os'=>"Windows 7", 'version'=>"8.0", 'vendor'=>"Microsoft"}
  # Detect type
  if ($$refWin->chUAOpt2->Checked()) {
    # Not detected, use another parser
    if (!$$refUA{'category'} or $$refUA{'category'} =~ /UNKNOWN/) {
      if (my $uaType = HTTP::BrowserDetect->new($uaStr)) {
        if    ($uaType->robot())  { $UAInfos .= 'crawler';    }
        elsif ($uaType->mobile()) { $UAInfos .= 'smartphone'; }
        elsif ($uaType->tablet()) { $UAInfos .= 'tablet';     }
        else                      { $UAInfos .= 'pc';         }
      }
    } elsif ($$refUA{'category'}) { $UAInfos .= $$refUA{'category'}; }
    $UAInfos .= "\t";
  }
  # Robot
  if ($$refUA{'category'} eq 'crawler') { }
  # pc or smartphone
  else {
    # Detect OS
    if ($$refWin->chUAOpt3->Checked()) {
      my $os;
      # Some particulars
      if    ($uaStr =~ /Windows NT 5.2/i) { $os = 'Windows XP Professional x64'; }
      elsif ($uaStr =~ /Ubuntu/i        ) { $os = 'Linux Ubuntu'; }
      elsif ($uaStr =~ /Iceweasel/i     ) { $os = 'Linux Debian'; }
      # Unknown, use another parser
      elsif (!$$refUA{'os'} or $$refUA{'os'} =~ /UNKNOWN/) {
        my $uaOS;
        eval { my $uaOS = Parse::HTTP::UserAgent->new($uaStr); };
        $os = $uaOS->os if !$@ and $uaOS and $uaOS->os;
      } else {
        $os  = $$refUA{'os'} if $$refUA{'os'};
        # Add version for MAC OS X
        $os .= " $$refUA{'os_version'}" if $os and $os =~ /Mac OSX/i and $$refUA{'os_version'} and $$refUA{'os_version'} !~ /UNKNOWN/;
      }
      $UAInfos .= $os  if $os;
      $UAInfos .= "\t";
    }
    # Detect browser
    if ($$refWin->chUAOpt4->Checked()) {
      my $browser;
      $browser  = $$refUA{'name'} if $$refUA{'name'} and $$refUA{'name'} !~ /UNKNOWN/;
      $browser  = 'Iceweasel'     if $uaStr =~ /Iceweasel/i;
      $browser  = 'Mobile Safari' if $uaStr =~ /Mobile/i and $uaStr =~ /Safari/;
      # Add Version
      $browser .= ' '.$$refUA{'version'} if $$refUA{'version'} and $$refUA{'version'} !~ /UNKNOWN/;
      $UAInfos .= $browser if $browser;
      $UAInfos .= "\t";
    }
    # Detect Device
    if ($$refWin->chUAOpt5->Checked()) {
      my $device;
      my $uaDevice = HTTP::BrowserDetect->new($uaStr);
      $device   = $uaDevice->device_name() if $uaDevice->device_name();
      $UAInfos .= $device if $device;
      $UAInfos .= "\t";
    }
    # Detect Lang
    if ($$refWin->chUAOpt6->Checked()) {
      my $lang;
      my $uaLang = HTML::ParseBrowser->new($uaStr);
      $lang      = $uaLang->language if $uaLang->language;
      # See https://msdn.microsoft.com/en-us/library/ms533052%28v=vs.85%29.aspx
      $UAInfos  .= $lang if $lang;
      $UAInfos  .= "\t";
    }
  }
  if ($UAInfos) {
    chop($UAInfos);
    return($UAInfos);
  }

}  #--- End parseUA

#--------------------------#
sub checkCC_IINDB
#--------------------------#
{
  # Local variables
  my ($cc, $refListIIN) = @_;
  my $issuer;
  # Check the card number with Business::CreditCard (Luhn Algorithm)
  my $genIssuer = &cardtype($cc);
  # If number valid, check in the IIN Database for a more precise result
  if ($genIssuer and $genIssuer ne 'Not a credit card') {
    my $exactIssuer;
    if ($cc =~ /(^[0-9]{2})/) {
      if (exists($$refListIIN{$1})) {
        foreach my $IIN (sort @{$$refListIIN{$1}}) {
          my ($prefix, $issuerName) = split(/\=/, $IIN);
          $exactIssuer = $issuerName if $cc =~ /^$prefix/;
        }
      }
    }
    if ($exactIssuer) { $issuer = $exactIssuer; }
    else              { $issuer = $genIssuer;   }
  }
  return($issuer) if $issuer and $issuer !~ /Unknown/i;
  return(undef);

}  #--- End checkCC_IINDB

#--------------------------#
sub checkCC_BinList
#--------------------------#
{
  # Local variables
  my ($cc, $refConfig) = @_;
  my $issuer;
  # Check the card number with Business::CreditCard (Luhn Algorithm)
  my $genIssuer = &cardtype($cc);
  # If number valid, send a query to Binlist.net
  if ($genIssuer and $genIssuer ne 'Not a credit card') {
    my $exactIssuer;
    my %data;
    if ($cc =~ /^([0-9]{6})/) { # Need only the first 6 digits
      my $ua = new LWP::UserAgent;
      $ua->agent($$refConfig{'USERAGENT'});
      $ua->default_header('Accept-Language' => 'en');
      my $client = REST::Client->new(useragent => $ua, timeout => $$refConfig{'NSLOOKUP_TIMEOUT'});
      $client->GET("https://www.binlist.net/json/$1");
      if ($client->responseCode() eq '200' and $client->responseContent()) {
        # Ex. response :
        #{
        #   "bin":"431940",
        #   "brand":"VISA",
        #   "sub_brand":"",
        #   "country_code":"IE",
        #   "country_name":"Ireland",
        #   "bank":"BANK OF IRELAND",
        #   "card_type":"DEBIT",
        #   "card_category":"",
        #   "latitude":"53",
        #   "longitude":"-8",
        #   "query_time":"365.845us"
        #}
        my @fields = split(/,/, $client->responseContent());
        foreach (@fields) { if (/\"([^\"]+)\"\:\"([^\"]*)\"/) { $data{$1} = $2; } }
        if ($data{brand})         { $exactIssuer .= "$data{brand}\t";         } else { $exactIssuer .= "\t"; }
        if ($data{sub_brand})     { $exactIssuer .= "$data{sub_brand}\t";     } else { $exactIssuer .= "\t"; }
        if ($data{bank})          { $exactIssuer .= "$data{bank}\t";          } else { $exactIssuer .= "\t"; }
        if ($data{card_type})     { $exactIssuer .= "$data{card_type}\t";     } else { $exactIssuer .= "\t"; }
        if ($data{card_category}) { $exactIssuer .= "$data{card_category}\t"; } else { $exactIssuer .= "\t"; }
        if ($data{country_name})  { $exactIssuer .= "$data{country_name}";    }
      }
    }
    $issuer = $exactIssuer if $exactIssuer;
  }
  return($issuer) if $issuer;
  return(undef);

}  #--- End checkCC_BinList

#--------------------------#
sub validCFDB
#--------------------------#
{
  # Local variables
  my $CFDBFile = shift;
  my $titleTableExists;
  my $dataTableExists;
  if (-f $CFDBFile) {
    # Connect to DB
    my $dsn = "DBI:SQLite:dbname=$CFDBFile";
    if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
      my $sth;
      eval { $sth = $dbh->table_info(undef, undef, '%', 'TABLE'); };
      return(0) if $@;
      # If tables TITLE and DATA exists, database is valid
      my $refAllRows = $sth->fetchall_arrayref();
      foreach my $refRow (@{$refAllRows}) {
        if    ($$refRow[2] eq 'TITLE') { $titleTableExists = 1; }
        elsif ($$refRow[2] eq 'DATA' ) { $dataTableExists  = 1; }
      }
      $sth->finish();
      $dbh->disconnect();
      return(1) if $titleTableExists and $dataTableExists;
    }
  }
  return(0);
  
}  #--- End validCFDB

#--------------------------#
sub validUniqueCFName
#--------------------------#
{
  # Local variables
  my ($title, $refWin) = @_;
  for (my $i = 0; $i < $$refWin->cbCFLists->Count(); $i++) {
    return(0) if $$refWin->cbCFLists->GetString($i) eq $title;
  }
  return(1); # Not found  
  
}  #--- End validUniqueCFName

#--------------------------#
sub validNewFunc
#--------------------------#
{
  my ($refWin, $refSTR) = @_;
  # To be valid, the new function:
  # - Must contains a title that doesn't already exist
  # - Number of items in List 1 and List 2 must be the same
  my $title = $$refWin->tfCFTitle->Text();
  my $refList1  = &enumItems(\$$refWin->tfList1, $refWin, $refSTR);
  my $refList2  = &enumItems(\$$refWin->tfList2, $refWin, $refSTR);
  my $nbrItems1 = scalar(@{$refList1});
  my $nbrItems2 = scalar(@{$refList2});
  if ($title and $nbrItems1 > 0 and $nbrItems2 > 0 and $nbrItems1 == $nbrItems2) { $$refWin->btnCFSave->Enable();  }
  else                                                                           { $$refWin->btnCFSave->Disable(); }

}  #--- End validNewFunc

#--------------------------#
sub editCF
#--------------------------#
{
  # Local variables
  my ($title, $dbFile, $refHOURGLASS, $refARROW, $refWin, $refSTR) = @_;
  # Show options and message
  $$refWin->lblCFTitle->Show();
  $$refWin->tfCFTitle->Show();
  $$refWin->btnCFSave->Show();
  $$refWin->btnCFCancel->Show();
  $$refWin->chCFMatchCase->Hide();
  $$refWin->cbCFLists->Disable();
  $$refWin->btnProcess->Disable();
  # Clean Lists
  $$refWin->tfList1->Text('');
  $$refWin->tfList2->Text('');
  # Show List 2
  &showList2();
  # Connect to database
  if ($dbFile) {
    threads->create(sub {
      my $list1;
      my $list2;
      my $dsn = "DBI:SQLite:dbname=$dbFile";
      if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
        $$refWin->ChangeCursor($$refHOURGLASS);
        # Write title
        $$refWin->tfCFTitle->Text($title);
        # Write the data
        my $all = $dbh->selectall_arrayref("SELECT * FROM DATA");
        foreach my $row (@$all) {
          my @values = @$row;
          if ($values[0] and $values[1]) {
            $list1 .= "$values[0]\r\n";
            $list2 .= "$values[1]\r\n";
          }
        }
        $dbh->disconnect();
        chomp($list1); chomp($list1);
        chomp($list2); chomp($list2);
        $$refWin->tfList1->Text($list1);
        $$refWin->tfList2->Text($list2);
        &tfList1_Change();
        &tfList2_Change();
        $$refWin->ChangeCursor($$refARROW);
      }
    });
  }
  
}  #--- End editCF

#--------------------------#
sub modCF
#--------------------------#
{
  # Local variables
  my ($title, $dbFile, $indexCF, $refList1, $refList2, $nbrItems1, $nbrItems2, $refHOURGLASS,
      $refARROW, $refWin, $refSTR) = @_;
  # Connect to database
  my $dsn = "DBI:SQLite:dbname=$dbFile";
  if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 0 })) {
    # Show progress
    $$refWin->lblPbCurr->Text('');
    $$refWin->pb->SetPos(0);
    $$refWin->lblPbCount->Text('');
    $$refWin->lblPbCurr->Show();
    $$refWin->pb->Show();
    $$refWin->lblPbCount->Show();
    $$refWin->ChangeCursor($$refHOURGLASS);
    $$refWin->pb->SetRange(0, $nbrItems1);
    $$refWin->pb->SetPos(0);
    $$refWin->pb->SetStep(1);
    $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
    $$refWin->lblPbCount->Text("0 / $nbrItems1");
    my $curr = 0;
    # Drop the existing table
    $dbh->do("DROP TABLE DATA");
    # Create a new DATA table
    my $stmt = qq(CREATE TABLE IF NOT EXISTS DATA
                  (key   VARCHAR(255)  NOT NULL,
                   value VARCHAR(255)  NOT NULL, 
                   PRIMARY KEY (key)));
    my $rv = $dbh->do($stmt);
    # Insert Data
    if ($rv >= 0) {
      $dbh->commit();
      my $sthData = $dbh->prepare("INSERT INTO DATA (key, value) VALUES(?,?)");
      for (my $i = 0; $i < $nbrItems1; $i++) {
        $sthData->execute($$refList1[$i], $$refList2[$i]) if $$refList1[$i] and $$refList2[$i];
        $dbh->commit() if $i % 1000 == 0;
        # Progress
        $curr++;
        $$refWin->lblPbCount->Text("$curr / $nbrItems1");
        $$refWin->pb->StepIt();
      }
    }
    $dbh->commit();
    $dbh->disconnect();
    # Progress
    $$refWin->lblPbCurr->Text('');
    $$refWin->pb->SetPos(0);
    $$refWin->lblPbCount->Text('');
    $$refWin->lblPbCurr->Hide();
    $$refWin->pb->Hide();
    $$refWin->lblPbCount->Hide();
    $$refWin->ChangeCursor($$refARROW);
  }

}  #--- End modCF

#--------------------------#
sub newCF
#--------------------------#
{
  # Local variables
  my ($title, $refList1, $refList2, $nbrItems1, $nbrItems2, $USERDIR, $refHOURGLASS, $refARROW,
      $refConfig, $CONFIG_FILE, $refWin, $refSTR) = @_;
  # Create default directory
  my $defCFDir = "$USERDIR\\Customs";
  mkdir($defCFDir) if !-d $defCFDir;
  # Show SaveFileWindow for database path
  my $tempName = $title;
  $tempName =~ s/[\<\>\:\"\/\\\|\?\*]/_/g; # Remove invalid char for a Windows filename
  my $CFDBFile = Win32::GUI::GetSaveFileName( -owner            => $$refWin                 ,
                                              -title            => $$refSTR{'selPathDB'}.':',
                                              -directory        => $defCFDir                ,
                                              -file             => "$tempName.db"           ,
                                              -filter           => [$$refSTR{'dbFile'}.' - .db', '.db'],
                                              -overwriteprompt  => 1                        , );
  if ($CFDBFile) {
    # Create the database
    my $dsn = "DBI:SQLite:dbname=$CFDBFile";
    if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 0 })) {
      # Show progress
      $$refWin->lblPbCurr->Text('');
      $$refWin->pb->SetPos(0);
      $$refWin->lblPbCount->Text('');
      $$refWin->lblPbCurr->Show();
      $$refWin->pb->Show();
      $$refWin->lblPbCount->Show();
      $$refWin->ChangeCursor($$refHOURGLASS);
      $$refWin->pb->SetRange(0, $nbrItems1);
      $$refWin->pb->SetPos(0);
      $$refWin->pb->SetStep(1);
      $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
      $$refWin->lblPbCount->Text("0 / $nbrItems1");
      my $curr = 0;
      $dbh->{sqlite_unicode} = 1;
      # Create the TITLE table
      my $stmt = qq(CREATE TABLE IF NOT EXISTS TITLE
                    (title  VARCHAR(255)  NOT NULL));
      my $rv = $dbh->do($stmt);
      # Insert Title
      my $sthTitle = $dbh->prepare("INSERT INTO TITLE (title) VALUES(?)");
      $sthTitle->execute($title);
      if ($rv >= 0) {
        # Create the DATA table
        $stmt = qq(CREATE TABLE IF NOT EXISTS DATA
                   (key   VARCHAR(255)  NOT NULL,
                    value VARCHAR(255)  NOT NULL, 
                    PRIMARY KEY (key)));
        my $rv = $dbh->do($stmt);
        # Insert Data
        if ($rv >= 0) {
          $dbh->commit();
          my $sthData = $dbh->prepare("INSERT INTO DATA (key, value) VALUES(?,?)");
          for (my $i = 0; $i < $nbrItems1; $i++) {
            $sthData->execute($$refList1[$i], $$refList2[$i]) if $$refList1[$i] and $$refList2[$i];
            $dbh->commit() if $i % 1000 == 0;
            # Progress
            $curr++;
            $$refWin->lblPbCount->Text("$curr / $nbrItems1");
            $$refWin->pb->StepIt();
          }
        }
      }
      $dbh->commit();
      $dbh->disconnect();
      # Update window and config
      my $j = 1;
      while (exists($$refConfig{'CF'.$j})) { $j++; }
      $$refConfig{'CF'.$j} = $title.'|'.$CFDBFile;
      &saveConfig($refConfig, $CONFIG_FILE);
      $$refWin->cbCFLists->Add($title);
      # Progress
      $$refWin->lblPbCurr->Text('');
      $$refWin->pb->SetPos(0);
      $$refWin->lblPbCount->Text('');
      $$refWin->lblPbCurr->Hide();
      $$refWin->pb->Hide();
      $$refWin->lblPbCount->Hide();
      $$refWin->ChangeCursor($$refARROW);
    }
  }

}  #--- End newCF

#--------------------------#
sub checkIP_WhoisDB_IPv4
#--------------------------#
{
  # Local variables
  my ($ip, $refDbh, $refWin, $refSTR) = @_;
  my $ipInt = unpack 'N', pack 'C4', split '\.', $ip;
  my $isp;
  my $country;
  my $date;
  my $interMin = 4294967295;
  # Check if IP address fit any range in database
  my $sth = $$refDbh->prepare("SELECT range_s,range_e,isp,country,date FROM WHOIS_DB WHERE $ipInt >= range_s AND $ipInt <= range_e");
  my $rv  = $sth->execute();
  if ($rv < 0) { Win32::GUI::MessageBox($$refWin, $$refSTR{'errDB'}.$DBI::errstr, $$refSTR{'error'}, 0x40010); }
  else {
    # Select the best answer (smaller range)
    my $refAllRows = $sth->fetchall_arrayref();
    foreach my $refRow (@{$refAllRows}) {
      my $inter = $$refRow[1] - $$refRow[0];
      if ($inter < $interMin) {
        $interMin = $inter;
        $isp      = $$refRow[2];
        $country  = $$refRow[3];
      }
    }
    return("$isp, $country") if $isp and $country;
  }
  return(undef);

}  #--- End checkIP_WhoisDB_IPv4

#--------------------------#
sub checkIP_WhoisDB_IPv6
#--------------------------#
{
  # Local variables
  my ($ip, $refDbh) = @_;
  # Check if IP address fit any range in database
  my $all = $$refDbh->selectall_arrayref("SELECT * FROM WHOIS_DB_6");
  foreach my $row (@$all) {
    my $cidr = @$row[0];
    return("@$row[1], @$row[2]") if Net::CIDR::cidrlookup($ip, ($cidr));
  }

}  #--- End checkIP_WhoisDB_IPv6

#------------------------------------------------------------------------------#
1;