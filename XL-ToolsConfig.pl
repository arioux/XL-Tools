#!/usr/bin/perl
# Perl - v: 5.16.3
#------------------------------------------------------------------------------#
# XL-ToolsConfig.pl	: Configuration functions for XL-Tools
# WebSite						: http://le-tools.com/XL-Tools.html
# SourceForge   		: https://sourceforge.net/p/xl-tools
# GitHub						: https://github.com/arioux/XL-Tools
# Documentation			: http://le-tools.com/XL-ToolsDoc.html
# Creation					: 2015-12-21
# Modified					: 2017-07-02
# Author						: Alain Rioux (admin@le-tools.com)
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
use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
use IO::Uncompress::Unzip qw(unzip $UnzipError);

#------------------------------------------------------------------------------#
# Global variables
#------------------------------------------------------------------------------#
my $URL_TOOL     = 'http://le-tools.com/XL-Tools.html#Download';               # Url of the tool
my $URL_VER      = 'http://www.le-tools.com/download/XL-ToolsVer.txt';         # Url of the version file
my $MACOUIDB_URL = 'http://standards-oui.ieee.org/oui.txt';                    # URL of the MAC OUI DB
my $GEOIPDB_URL  = 'http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz'; # URL of the GeoIP DB
my $IINDB_URL    = 'http://le-tools.com/download/XL-Tools/IIN.zip';            # URL of the IINDB
my $DTDB_URL     = 'http://le-tools.com/download/XL-Tools/Datetime.zip';       # URL of the DTDB
my $TOTAL_SIZE:shared = 0;                                                     # Total size for download

#--------------------------#
sub saveConfig
#--------------------------#
{
  # Local variables
  my $refConfig   = shift;
  my $CONFIG_FILE = shift;
  # Save configuration hash values
  open(CONFIG,">$CONFIG_FILE");
  flock(CONFIG, 2);
  foreach my $cle (keys %{$refConfig}) { print CONFIG "$cle = $$refConfig{$cle}\n"; }
  close(CONFIG);

}  #--- End saveConfig

#--------------------------#
sub loadConfig
#--------------------------#
{
  # Local variables
  my ($refConfig, $CONFIG_FILE, $refWinConfig, $refWinDTDB, $refWin) = @_;
  # Open and load config values
  open(CONFIG, $CONFIG_FILE);
  my @tab = <CONFIG>;
  close(CONFIG);
  foreach (@tab) {
    chomp($_);
    my ($key, $value) = split(/ = /, $_);
    $$refConfig{$key}  = $value if $key;
  }
  # General tab
  if (exists($$refConfig{'TOOL_AUTO_UPDATE'})) { $$refWinConfig->chAutoUpdate->Checked($$refConfig{'TOOL_AUTO_UPDATE'}); }
  else                                         { $$refWinConfig->chAutoUpdate->Checked(1);                               } # Default checked
  # Function options
  if (exists($$refConfig{'FULL_SCREEN'}))      { $$refWinConfig->chFullScreen->Checked($$refConfig{'FULL_SCREEN'});      }
  else                                         { $$refWinConfig->chFullScreen->Checked(0);                               } # Default is not checked
  if (exists($$refConfig{'REMEMBER_POS'}))     { $$refWinConfig->chRememberPos->Checked($$refConfig{'REMEMBER_POS'});    }
  else                                         { $$refWinConfig->chRememberPos->Checked(0);                              } # Default is not checked
  if (exists($$refConfig{'MAX_SIZE_LIST'}))    { $$refWinConfig->tfMaxSize->Text($$refConfig{'MAX_SIZE_LIST'});          }
  else                                         { $$refWinConfig->tfMaxSize->Text(5000000);
                                                 $$refConfig{'MAX_SIZE_LIST'} = 5000000;                                 } # Default is 5 000 000 chars
  $$refWin->tfList1->MaxLength($$refConfig{'MAX_SIZE_LIST'});
  $$refWin->tfList2->MaxLength($$refConfig{'MAX_SIZE_LIST'});
  $$refWin->tfList3->MaxLength($$refConfig{'MAX_SIZE_LIST'});
  if (exists($$refConfig{'NSLOOKUP_TIMEOUT'})) { $$refWinConfig->tfLookupTO->Text($$refConfig{'NSLOOKUP_TIMEOUT'});          }
  else                                         { $$refWinConfig->tfLookupTO->Text(10); $$refConfig{'NSLOOKUP_TIMEOUT'} = 10; } # Default is 10 seconds
  if (exists($$refConfig{'USERAGENT'}))        { $$refWinConfig->tfUserAgent->Text($$refConfig{'USERAGENT'});                }
  else                                         { $$refWinConfig->tfUserAgent->Text('XL-Tools (http://www.le-tools.com)');
                                                 $$refConfig{'USERAGENT'} = 'XL-Tools (http://www.le-tools.com)';            } # Use default
  if (exists($$refConfig{'LOCAL_TIMEZONE'}))   { $$refWinDTDB->cbLocalTZ->SetCurSel($$refConfig{'LOCAL_TIMEZONE'});          }
  else { # Try to find local timezone, if not found, set to America/New York
    my $index = 107;
    my $localTZ;
    eval { $localTZ = DateTime::TimeZone->new(name => 'local'); };
    $index = $$refWinDTDB->cbLocalTZ->FindStringExact($localTZ->{name}) if !$@;
    $$refWinDTDB->cbLocalTZ->SetCurSel($index);
    $$refConfig{'LOCAL_TIMEZONE'} = $index;
  }
  if (exists($$refConfig{'DEFAULT_LANG'})) {
    my $index = $$refWinDTDB->cbDefaultLang->FindStringExact($$refConfig{'DEFAULT_LANG'});
    $$refWinDTDB->cbDefaultLang->SetCurSel($index);
  } else {
    $$refWinDTDB->cbDefaultLang->SetCurSel($$refWinDTDB->cbDefaultLang->FindStringExact('en-US')); # Use default
    $$refConfig{'DEFAULT_LANG'} = 'en-US';
  }
  if (exists($$refConfig{'OUTPUT_CHARSET'})) {
    $$refWinDTDB->cbOutputCharset->SetCurSel($$refWinDTDB->cbOutputCharset->FindString($$refConfig{'OUTPUT_CHARSET'}));
  } else { $$refWinDTDB->cbOutputCharset->SetCurSel(0); $$refConfig{'OUTPUT_CHARSET'} = 'cp1252'; } # Default is cp1252
  if (exists($$refConfig{'NO_RESULT_OPT'})) {
    if ($$refConfig{'NO_RESULT_OPT'} == 1) {
      $$refWinConfig->rbNoResultOpt1->Checked(1); $$refWinConfig->rbNoResultOpt2->Checked(0);
    } else { $$refWinConfig->rbNoResultOpt2->Checked(1); $$refWinConfig->rbNoResultOpt1->Checked(0); }
  } else { $$refWinConfig->rbNoResultOpt1->Checked(1); } # Default is Opt1 : Leave a blank
  # MACOUIDB Database location
  if (exists($$refConfig{'MACOUI_DB_AUTO_UPDATE'})) {
    $$refWinConfig->chMACOUIDBAutoUpt->Checked($$refConfig{'MACOUI_DB_AUTO_UPDATE'});
  } else { $$refWinConfig->chMACOUIDBAutoUpt->Checked(0); } # Default is not checked
  $$refWinConfig->tfMACOUIDB->Text($$refConfig{'MACOUI_DB_FILE'}) if exists($$refConfig{'MACOUI_DB_FILE'}) and
                                                                 -f $$refConfig{'MACOUI_DB_FILE'};
  # GeoIPDB Database location
  if (exists($$refConfig{'GEOIP_DB_AUTO_UPDATE'})) {
    $$refWinConfig->chGeoIPDBAutoUpt->Checked($$refConfig{'GEOIP_DB_AUTO_UPDATE'});
  } else { $$refWinConfig->chGeoIPDBAutoUpt->Checked(1); } # Default is checked
  $$refWinConfig->tfGeoIPDB->Text($$refConfig{'GEOIP_DB_FILE'}) if exists($$refConfig{'GEOIP_DB_FILE'}) and
                                                               -f $$refConfig{'GEOIP_DB_FILE'};
  # IIN Database location
  $$refWinConfig->tfIINDB->Text($$refConfig{'IIN_DB_FILE'}) if exists($$refConfig{'IIN_DB_FILE'}) and -f $$refConfig{'IIN_DB_FILE'};
  # XL-Whois Database location
  $$refWinConfig->tfXLWHOISDB->Text($$refConfig{'XLWHOIS_DB_FILE'}) if exists($$refConfig{'XLWHOIS_DB_FILE'}) and
                                                                   -f $$refConfig{'XLWHOIS_DB_FILE'};
  # Datetime Database location
  $$refWinConfig->tfDTDB->Text($$refConfig{'DT_DB_FILE'}) if exists($$refConfig{'DT_DB_FILE'}) and -f $$refConfig{'DT_DB_FILE'};
  # Datetime Database location
  $$refWin->tfAPIKey->Text($$refConfig{'GOOGLE_API_KEY'}) if exists($$refConfig{'GOOGLE_API_KEY'});
  # Custom Functions
  my $j = 1;
  while (exists($$refConfig{'CF'.$j})) {
    my ($title, $dbFile) = split(/\|/, $$refConfig{'CF'.$j});
    $$refWin->cbCFLists->Add($title);
    $j++;
  }

}  #--- End loadConfig

#--------------------------#
sub updateAll
#--------------------------#
{
  my ($VERSION, $USERDIR, $refHOURGLASS, $refARROW, $refWinConfig, $refConfig, $CONFIG_FILE, $refWinPb, $refWin, $refSTR) = @_;
  # Thread 'cancellation' signal handler
  $SIG{'KILL'} = sub {
    # Delete temp files if converting was in progress
    if (-e $$refWinConfig->tfMACOUIDB->Text().'-journal') {
      my $localMACOUIDB = $$refWinConfig->tfMACOUIDB->Text();
      unlink($localMACOUIDB.'-journal');
      unlink($localMACOUIDB);
    }
    $$refWin->ChangeCursor($$refARROW);
    # Turn off progress bar
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    threads->exit();
  };
  # Thread 'die' signal handler
  $SIG{__DIE__} = sub {
    # Delete temp files if converting was in progress
    if (-e $$refWinConfig->tfMACOUIDB->Text().'-journal') {
      my $localMACOUIDB = $$refWinConfig->tfMACOUIDB->Text();
      unlink($localMACOUIDB.'-journal');
      unlink($localMACOUIDB);
    }
    my $errMsg = (split(/ at /,$_[0]))[0];
    chomp($errMsg);
    $errMsg =~ s/[\t\r\n]/ /g;
    $$refWin->ChangeCursor($$refARROW);
    # Turn off progress bar
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    Win32::GUI::MessageBox($$refWin, "$$refSTR{'errorMsg'}: $errMsg", $$refSTR{'error'}, 0x40010);
  };
  sleep(1);
  &updateTool(    0, $VERSION, $refWinConfig, $refWin, $refSTR) if $$refConfig{'TOOL_AUTO_UPDATE'};      # Update Tool ?
  &updateGeoIPDB( 0, $VERSION, $USERDIR, $refHOURGLASS, $refARROW, $refWinConfig, $refConfig,
                  $CONFIG_FILE, $refWinPb, $refWin, $refSTR)    if $$refConfig{'GEOIP_DB_AUTO_UPDATE'};  # Update GeoIP DB ?
  &updateMACOUIDB(0, $VERSION, $USERDIR, $refHOURGLASS, $refARROW, $refWinConfig, $refConfig,
                  $CONFIG_FILE, $refWinPb, $refWin, $refSTR)    if $$refConfig{'MACOUI_DB_AUTO_UPDATE'}; # Update MACOUI DB ?
  
}  #--- End updateAll

#--------------------------#
sub updateTool
#--------------------------#
{
  # Local variables
  my ($confirm, $VERSION, $refWinConfig, $refWin, $refSTR) = @_;
  # Download the version file  
  my $ua = new LWP::UserAgent;
  $ua->agent("XL-Tools Update $VERSION");
  $ua->default_header('Accept-Language' => 'en');
  my $req = new HTTP::Request GET => $URL_VER;
  my $res = $ua->request($req);
  # Success, compare versions
  if ($res->is_success) {
    my $status  = $res->code;
    my $content = $res->content;
    my $currVer;
    if ($content =~ /([\d\.]+)/i) { $currVer = $1; }
    # No update available
    if ($currVer le $VERSION) {
      Win32::GUI::MessageBox($$refWinConfig, $$refSTR{'update1'}, $$refSTR{'update2'}, 0x40040) if $confirm; # Up to date
    } else {
      # Download with browser
      my $answer = Win32::GUI::MessageBox($$refWinConfig, "$$refSTR{'update4'} $currVer $$refSTR{'update5'} ?", $$refSTR{'update3'}, 0x40024);
      if ($answer == 6) {
        # Open XL-Tools page with default browser
        $$refWin->ShellExecute('open', $URL_TOOL,'','',1) or
        Win32::GUI::MessageBox($$refWinConfig, Win32::FormatMessage(Win32::GetLastError()), "$$refSTR{'update3'} XL-Tools", 0x40010);
      }
    }
  } elsif ($confirm) { # Error 
    Win32::GUI::MessageBox($$refWinConfig, $$refSTR{'errorConnection'}.': '.$res->status_line, "$$refSTR{'update3'} XL-Tools", 0x40010);
  }

}  #--- End updateTool

#--------------------------#
sub validMACOUIDB
#--------------------------#
{
  # Local variables
  my $MACOUIDBFile = shift;
  if (-f $MACOUIDBFile) {
    # Connect to DB
    my $dsn = "DBI:SQLite:dbname=$MACOUIDBFile";
    if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
      my $sth;
      eval { $sth = $dbh->table_info(undef, undef, '%', 'TABLE'); };
      return(0) if $@;
      # If table MACOUI exists, database is valid
      my @info = $sth->fetchrow_array;
      $sth->finish();
      return(1) if $info[2] eq 'MACOUI';
    }
  }
  return(0);
  
}  #--- End validMACOUIDB

#--------------------------#
sub updateMACOUIDB
#--------------------------#
{
  # This function may be called in 2 ways
  # 1. User click on the update button ($confirm == 1)
  # 2. Auto update at start up: If database is up to date, we don't show message
  
  # Local variables
	my ($confirm, $VERSION, $USERDIR, $refHOURGLASS, $refARROW, $refWinConfig, $refConfig, $CONFIG_FILE, $refWinPb, $refWin, $refSTR) = @_;
  my ($upToDate, $return, $dateLocalFile, $dateRemoteFile) = &checkDateMACOUIDB($refWinConfig, $refConfig);
  # Values for $upToDate
  # 0: MAC OUI Database doesn't exist
  # 1: Database is up to date
  # 2: Database is outdated
  # 3: Error connection
  # 4: Unknown error

  # MAC OUI Database is outdated or doesn't exist
  if (!$upToDate or $upToDate == 2) {
    my $msg;
    if ($dateLocalFile and $dateRemoteFile) {
      Encode::from_to($dateRemoteFile, 'utf8', 'iso-8859-1');
      $msg = "$$refSTR{'currDBDate'}: $dateLocalFile\n$$refSTR{'remoteDBDate'} ieee.org: $dateRemoteFile\n\n$$refSTR{'updateAvailable'} ?";
    } else { $msg = "$$refSTR{'MACOUINotExist'} ?"; }
    # Yes (6), No (7)
    my $answer = Win32::GUI::MessageBox($$refWin, $msg, $$refSTR{'uptMACOUI'}, 0x1024);
    # Answer is No
    if ($answer == 7) { return(0); }
    # Answer is Yes, download the update
    else {
      my $return = &downloadMACOUIDB($$refWinConfig->tfMACOUIDB->Text(), $USERDIR, $refHOURGLASS, $refARROW,
                                     $refWinConfig, $refConfig, $CONFIG_FILE, $refWinPb, $refWin, $refSTR); # $return contains error msg if any
      $$refWin->lblCurrMACOUIdbDate->Text("$$refSTR{'currDBDate'}: ". $dateRemoteFile);
      $$refWin->btnMACOUIdbUpdate->Text($$refSTR{'winUpdate'}.'...');
      if ($return) { Win32::GUI::MessageBox($$refWin, $return, $$refSTR{'error'}, 0x40010);                     }
      else         { Win32::GUI::MessageBox($$refWin, $$refSTR{'updatedMACOUI'}.'!', "XL-Tools $VERSION", 0x40040); }
    }
  # MAC OUI is up to date, show message if $confirm == 1
  } elsif ($upToDate == 1) {
    if ($confirm) {
      Encode::from_to($dateRemoteFile, 'utf8', 'iso-8859-1');
      Win32::GUI::MessageBox($$refWin, "$$refSTR{'currDBDate'}: $dateLocalFile\n$$refSTR{'remoteDBDate'} ieee.org: ".
                                       "$dateRemoteFile\n\n$$refSTR{'DBUpToDate'} !", $$refSTR{'uptMACOUI'}, 0x40040);
    }
  # Connection error, show message if $confirm == 1
  } elsif (($upToDate == 3 or $upToDate == 4) and $confirm) {
    if ($upToDate == 3) { Win32::GUI::MessageBox($$refWin, "$$refSTR{'errorConnection'}: $return", $$refSTR{'error'}, 0x40010); }
    else                { Win32::GUI::MessageBox($$refWin, "$$refSTR{'unknownError'}: $return", $$refSTR{'error'}   , 0x40010); }
  }

}  #--- End updateMACOUIDB

#--------------------------#
sub checkDateMACOUIDB
#--------------------------#
{
  # Local variables
  my ($refWinConfig, $refConfig) = @_;
  my $localMACOUIDB = $$refWinConfig->tfMACOUIDB->Text();
  my $lastModifDate;
  # MAC OUI Database doesn't exist or invalid file
  return(0, undef, undef, undef) if !$localMACOUIDB or !-f $localMACOUIDB;
  # Check date of local file
  my $localFileT  = DateTime->from_epoch(epoch => (stat($localMACOUIDB))[9]);
  # Check date of the remote file
  my $ua = new LWP::UserAgent;
  $ua->agent($$refConfig{'USERAGENT'});
  $ua->default_header('Accept-Language' => 'en');
  my $req    = new HTTP::Request HEAD => $MACOUIDB_URL;
  my $res    = $ua->request($req);
  my $return = $res->status_line;
  if ($res->code == 200) {
    $lastModifDate = $res->header('last-modified');
    $TOTAL_SIZE    = $res->header('content_length');
  } else { return(3, $return, undef, undef); } # Error connection
  # Compare local et remote file date
  my $strp2 = DateTime::Format::Strptime->new(pattern => '%a, %d %b %Y %T %Z');
  if (my $lastModifT = $strp2->parse_datetime($lastModifDate)) {
    my $cmp = DateTime->compare($localFileT, $lastModifT);
    if ($cmp > -1) { return(1, $return, $localFileT->ymd(), $lastModifT->ymd()); } # MACOUIDB is up to date 
    else           { return(2, $return, $localFileT->ymd(), $lastModifT->ymd()); } # MACOUIDB is outdated
  } else           { return(3, $return, undef             , undef             ); } # Connection error

}  #--- End checkDateMACOUIDB

#--------------------------#
sub downloadMACOUIDB
#--------------------------#
{
  # Local variables
  my ($localMACOUIDB, $USERDIR, $refHOURGLASS, $refARROW, $refWinConfig, $refConfig, $CONFIG_FILE,
      $refWinPb, $refWin, $refSTR) = @_;
  $localMACOUIDB = "$USERDIR\\oui.db" if !$localMACOUIDB; # Default location
  # Start an agent
  my $ua = new LWP::UserAgent;
  $ua->agent($$refConfig{'USERAGENT'});
  $ua->default_header('Accept-Language' => 'en');
  # Set the progress bar
  $$refWin->ChangeCursor($$refHOURGLASS);
  $$refWinPb->Text($$refSTR{'downloadMACOUI'});
  $$refWinPb->lblPbCurr->Text($$refSTR{'connecting'}.' ieee.org...');
  $$refWinPb->lblCount->Text("0 %");
  $$refWinPb->pbWinPb->SetRange(0, 100);
  $$refWinPb->pbWinPb->SetPos(0);
  $$refWinPb->pbWinPb->SetStep(1);
  $$refWinPb->Center($$refWin);
  $$refWinPb->Show();
  # Check size of the remote file
  if (!$TOTAL_SIZE) {
    my $req    = new HTTP::Request HEAD => $MACOUIDB_URL;
    my $res    = $ua->request($req);
    my $return = $res->status_line;
    if ($res->code == 200) { $TOTAL_SIZE = $res->header('content_length'); }
    else {
      # Turn off progress bar
      $$refWin->ChangeCursor($$refARROW);
      $$refWinPb->lblPbCurr->Text('');
      $$refWinPb->lblCount->Text('');
      $$refWinPb->pbWinPb->SetPos(0);
      $$refWinPb->Hide();
      return("$$refSTR{'errorMsg'}: $$refSTR{'errorConRemote'}...");
    }
  }
  # Download the file
  if ($TOTAL_SIZE) {
    my $downloadData;
    # Download the file
    $$refWinPb->lblPbCurr->Text("$$refSTR{'downloadMACOUI'}. $$refSTR{'downloadWarning'}...");
    my $response = $ua->get($MACOUIDB_URL, ':content_cb' => sub {
      # Local variables
      my ($data, $response, $protocol) = @_;
      $downloadData       .= $data;                                     # Downloaded data
      my $totalDownloaded  = length($downloadData);                     # Size of downloaded data
      my $completed        = int($totalDownloaded / $TOTAL_SIZE * 100); # Pourcentage of download completed
      $$refWinPb->pbWinPb->SetPos($completed);    # Set the progress bar
      $$refWinPb->lblCount->Text("$completed %"); # Indicate purcentage
    }, ':read_size_hint' => 32768);
    # Save data in a temp file
    my $ouiFileTemp = $localMACOUIDB . '.txt';
    if ($response and $response->is_success) {
      open(OUI_TEMP,">$ouiFileTemp");
      print OUI_TEMP $downloadData;
      close(OUI_TEMP);
    }
    $downloadData = undef;
    # Convert the downloaded data into a SQLite database
    if (-T $ouiFileTemp) {
      $TOTAL_SIZE = 0;
      return(&importMACOUIDatabase(1, $refARROW, $localMACOUIDB, $ouiFileTemp, $refWinConfig, $refConfig,
                                   $CONFIG_FILE, $refWinPb, $refWin, $refSTR));
    }
  } else {
    # Turn off progress bar
    $$refWin->ChangeCursor($$refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    return("$$refSTR{'errorMsg'}: $$refSTR{'errorDownload'}...");
  }
  $TOTAL_SIZE = 0;
  
}  #--- End downloadMACOUIDB

#--------------------------#
sub importMACOUIDatabase
#--------------------------#
{
  # This function may be called in 2 ways
  # 1. User click on the import button using a local oui.txt
  # 2. Database is downloaded
  # Return error or return 0 if successful
  
  # Local variables
  my ($statusWinPb, $refARROW, $localMACOUIDB, $ouiFileTemp, $refWinConfig, $refConfig,
      $CONFIG_FILE, $refWinPb, $refWin, $refSTR) = @_;
  # If $statusWinPb == 1, WinPb is already displayed
  my %oui;
  # Show Progress Window
  if (!$statusWinPb) {
    $$refWinPb->Center($$refWin);
    $$refWinPb->Show();
  }
  # Set Progress Bar
  $$refWinPb->Text($$refSTR{'convertMACOUI'});
  $$refWinPb->lblPbCurr->Text('');
  $$refWinPb->lblCount->Text('');
  $$refWinPb->pbWinPb->SetPos(0);
  # Open the oui file and store prefix and minimal info about organization
  open my $ouiFH, '<', $ouiFileTemp;
  while (<$ouiFH>) {
    if (/((?:[a-fA-F0-9]{2}\-){2}[a-fA-F0-9]{2})\s+\(hex\)\t+([^\n\r]+)(?:$|[\n\r])/) {
      my $prefix    = $1;
      my $oui       = $2;
      $prefix       =~ s/\-//g;
      $oui{$prefix} = $oui;
    }
  }
  close($ouiFH);
  my $nbrOUI = scalar(keys %oui);
  if ($nbrOUI) {
    if (-f $localMACOUIDB) { # Delete last database file
      unlink($localMACOUIDB);
      $$refWinConfig->tfMACOUIDB->Text('');
    }
    # Create the database and the table
    $$refWinPb->lblPbCurr->Text($$refSTR{'createDBTable'}.'...');
    my $dsn = "DBI:SQLite:dbname=$localMACOUIDB";
    if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 0 })) {
      # Create the table
      my $stmt = qq(CREATE TABLE IF NOT EXISTS MACOUI
                    (prefix VARCHAR(8)    NOT NULL,
                     org    VARCHAR(150)  NOT NULL,
                     PRIMARY KEY(prefix)));
      if (my $rv = $dbh->do($stmt)) {
        # Add data
        my $curr = 0;
        $$refWinPb->lblCount->Text("0 / $nbrOUI");
        $$refWinPb->pbWinPb->SetRange(0, $nbrOUI);
        $$refWinPb->pbWinPb->SetPos(0);
        $$refWinPb->pbWinPb->SetStep(1);
        my $sth = $dbh->prepare('INSERT OR REPLACE INTO MACOUI (prefix,org) VALUES(?,?)');
        foreach my $prefix (keys %oui) {
          $$refWinPb->lblPbCurr->Text("$$refSTR{'inserting'} $prefix...");
          my $rv = $sth->execute($prefix, $oui{$prefix});
          $curr++;
          $dbh->commit() if $curr % 1000 == 0;
          # Update progress bar
          $$refWinPb->lblCount->Text("$curr / $nbrOUI");
          $$refWinPb->pbWinPb->StepIt();
        }
      }
      $dbh->commit();
      $dbh->disconnect();
      # Turn off progress bar
      $$refWin->ChangeCursor($$refARROW);
      $$refWinPb->lblPbCurr->Text('');
      $$refWinPb->lblCount->Text('');
      $$refWinPb->pbWinPb->SetPos(0);
      $$refWinPb->Hide();
      # Final message
      if (&validMACOUIDB($localMACOUIDB)) {
        unlink($ouiFileTemp);
        $$refWinConfig->tfMACOUIDB->Text($localMACOUIDB);
        $$refConfig{'MACOUI_DB_FILE'} = $localMACOUIDB;
        &saveConfig($refConfig, $CONFIG_FILE);
        $$refWinConfig->tfMACOUIDB->Text($localMACOUIDB);
        return(0);
      } else { return("$$refSTR{'errorMsg'}: $$refSTR{'errorCreatingDB'}..."); }
    } else {
      # Turn off progress bar
      $$refWin->ChangeCursor($$refARROW);
      $$refWinPb->lblPbCurr->Text('');
      $$refWinPb->lblCount->Text('');
      $$refWinPb->pbWinPb->SetPos(0);
      $$refWinPb->Hide();
      return("$$refSTR{'errorMsg'}: $$refSTR{'errorConnectDB'}...");
    }
  } else {
    # Turn off progress bar
    $$refWin->ChangeCursor($$refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    return("$$refSTR{'errorMsg'}: $$refSTR{'errorOUI_TXT'}...");
  }

}  #--- End importMACOUIDatabase

#--------------------------#
sub validGeoIPDB
#--------------------------#
{
  # Local variables
  my $GeoIPDBFile = shift;
  if (-f $GeoIPDBFile and my $gi = Geo::IP->open($GeoIPDBFile)) {
    return(1) if my $info = $gi->database_info;
  }
  return(0);
  
}  #--- End validGeoIPDB

#--------------------------#
sub updateGeoIPDB
#--------------------------#
{
  # This function may be called in 2 ways
  # 1. User click on the update button ($confirm == 1)
  # 2. Auto update at start up: If database is up to date, we don't show message
  
  # Local variables
	my ($confirm, $VERSION, $USERDIR, $refHOURGLASS, $refARROW, $refWinConfig, $refConfig, $CONFIG_FILE, $refWinPb,
      $refWin, $refSTR)  = @_;
  my ($upToDate, $return, $dateLocalFile, $dateRemoteFile) = &checkDateGeoIPDB($refWinConfig, $refConfig);
  # Values for $upToDate
  # 0: GeoIP Database doesn't exist  
  # 1: Database is up to date
  # 2: Database is outdated
  # 3: Error connection
  # 4: Unknown error

  # GeoIP Database is outdated or doesn't exist
  if (!$upToDate or $upToDate == 2) {
    my $msg;
    if ($dateLocalFile and $dateRemoteFile) {
      Encode::from_to($dateRemoteFile, 'utf8', 'iso-8859-1');
      $msg = "$$refSTR{'currDBDate'}: $dateLocalFile\n$$refSTR{'remoteDBDate'} Maxmind: $dateRemoteFile\n\n$$refSTR{'updateAvailable'} ?";
    } else { $msg = "$$refSTR{'GeoIPNotExist'} ?"; }
    # Yes (6), No (7)
    my $answer = Win32::GUI::MessageBox($$refWin, $msg, $$refSTR{'uptGeoIP'}, 0x1024);
    # Answer is No
    if ($answer == 7) { return(0); }
    # Answer is Yes, download the update
    else {
      my $return = &downloadGeoIPDB($$refWinConfig->tfGeoIPDB->Text(), $USERDIR, $refHOURGLASS, $refARROW, $refWinConfig, $refConfig, $CONFIG_FILE,
      $refWinPb, $refWin, $refSTR); # $return contains error msg if any
      if ($return) { Win32::GUI::MessageBox($$refWin, $return, $$refSTR{'error'}, 0x40010);                    }
      else         { Win32::GUI::MessageBox($$refWin, $$refSTR{'updatedGeoIP'}, "XL-Tools $VERSION", 0x40040); }
    }
  # GeoIP is up to date, show message if $confirm == 1
  } elsif ($upToDate == 1) {
    if ($confirm) {
      Encode::from_to($dateRemoteFile, 'utf8', 'iso-8859-1');
      Win32::GUI::MessageBox($$refWin, "$$refSTR{'currDBDate'}: $dateLocalFile\n$$refSTR{'remoteDBDate'} Maxmind: ".
                                       "$dateRemoteFile\n\n$$refSTR{'DBUpToDate'} !", $$refSTR{'uptGeoIP'}, 0x40040);
    }
  # Connection error, show message if $confirm == 1
  } elsif (($upToDate == 3 or $upToDate == 4) and $confirm) {
    if ($upToDate == 3) { Win32::GUI::MessageBox($$refWin, "$$refSTR{'errorConnection'}: $return", $$refSTR{'error'}, 0x40010); }
    else                { Win32::GUI::MessageBox($$refWin, "$$refSTR{'unknownError'}: $return", $$refSTR{'error'}   , 0x40010); }
  }

}  #--- End updateGeoIPDB

#--------------------------#
sub checkDateGeoIPDB
#--------------------------#
{
  # Local variables
  my ($refWinConfig, $refConfig) = @_;
  my $localGeoIPDB = $$refWinConfig->tfGeoIPDB->Text();
  my $lastModifDate;
  # GeoIP Database doesn't exist or invalid file
  return(0, undef, undef, undef) if !$localGeoIPDB or !-f $localGeoIPDB;
  # Check date of local file
  my $localFileT  = DateTime->from_epoch(epoch => (stat($localGeoIPDB))[9]);
  # Check date of the remote file
  my $ua = new LWP::UserAgent;
  $ua->agent($$refConfig{'USERAGENT'});
  $ua->default_header('Accept-Language' => 'en');
  my $req    = new HTTP::Request HEAD => $GEOIPDB_URL;
  my $res    = $ua->request($req);
  my $return = $res->status_line;
  if ($res->code == 200) {
    $lastModifDate = $res->header('last-modified');
    $TOTAL_SIZE    = $res->header('content_length');
  } else { return(3, $return, undef, undef); } # Error connection
  # Compare local et remote file date
  my $strp2 = DateTime::Format::Strptime->new(pattern => '%a, %d %b %Y %T %Z');
  if (my $lastModifT = $strp2->parse_datetime($lastModifDate)) {
    my $cmp = DateTime->compare($localFileT, $lastModifT);
    if ($cmp > -1) { return(1, $return, $localFileT->ymd(), $lastModifT->ymd()); } # GeoIPDB is up to date 
    else           { return(2, $return, $localFileT->ymd(), $lastModifT->ymd()); } # GeoIPDB is outdated
  } else           { return(3, $return, undef             , undef             ); } # Connection error

}  #--- End checkDateGeoIPDB

#--------------------------#
sub downloadGeoIPDB
#--------------------------#
{
  # Local variables
  my ($localGeoIPDB, $USERDIR, $refHOURGLASS, $refARROW, $refWinConfig, $refConfig, $CONFIG_FILE,
      $refWinPb, $refWin, $refSTR) = @_; # Local filepath
  $localGeoIPDB = "$USERDIR\\GeoLiteCity.dat" if !$localGeoIPDB; # Default location
  # Start an agent
  my $ua = new LWP::UserAgent;
  $ua->agent($$refConfig{'USERAGENT'});
  $ua->default_header('Accept-Language' => 'en');
  # Set the progress bar
  $$refWin->ChangeCursor($$refHOURGLASS);
  $$refWinPb->Text($$refSTR{'downloadGeoIP'});
  $$refWinPb->lblPbCurr->Text($$refSTR{'connecting'}.' Maxmind...');
  $$refWinPb->lblCount->Text("0 %");
  $$refWinPb->pbWinPb->SetRange(0, 100);
  $$refWinPb->pbWinPb->SetPos(0);
  $$refWinPb->pbWinPb->SetStep(1);
  $$refWinPb->Center($$refWin);
  $$refWinPb->Show();
  # Check size of the remote file
  if (!$TOTAL_SIZE) {
    my $req    = new HTTP::Request HEAD => $GEOIPDB_URL;
    my $res    = $ua->request($req);
    my $return = $res->status_line;
    if ($res->code == 200) { $TOTAL_SIZE = $res->header('content_length'); }
    else {
      # Turn off progress bar
      $$refWin->ChangeCursor($$refARROW);
      $$refWinPb->lblPbCurr->Text('');
      $$refWinPb->lblCount->Text('');
      $$refWinPb->pbWinPb->SetPos(0);
      $$refWinPb->Hide();
      return("$$refSTR{'errorMsg'}: $$refSTR{'errorConRemote'}...");
    }
  }
  # Download the file
  if ($TOTAL_SIZE) {
    my $downloadData;
    # Download the file
    $$refWinPb->lblPbCurr->Text($$refSTR{'downloadGeoIP'}.'...');
    my $response = $ua->get($GEOIPDB_URL, ':content_cb' => sub {
      # Local variables
      my ($data, $response, $protocol) = @_;
      $downloadData       .= $data;                                     # Downloaded data
      my $totalDownloaded  = length($downloadData);                     # Size of downloaded data
      my $completed        = int($totalDownloaded / $TOTAL_SIZE * 100); # Pourcentage of download completed
      $$refWinPb->pbWinPb->SetPos($completed);    # Set the progress bar
      $$refWinPb->lblCount->Text("$completed %"); # Indicate purcentage
    });
    # Save data in a temp file
    my $GeoIPGZIP = $localGeoIPDB . '.gz';
    if ($response and $response->is_success) {
      open(GEOIPGZ,">$GeoIPGZIP");
      binmode(GEOIPGZ);
      print GEOIPGZ $downloadData;
      close(GEOIPGZ);
    }
    $downloadData = undef;
    # Uncompress GEOIP GZIP
    my ($error, $msg);
    if (-e $GeoIPGZIP) {
      $TOTAL_SIZE = 0;
      if (gunzip $GeoIPGZIP => $localGeoIPDB, BinModeOut => 1) {
        if (&validGeoIPDB($localGeoIPDB)) {
          unlink $GeoIPGZIP;
          $$refWinConfig->tfGeoIPDB->Text($localGeoIPDB);
          $$refConfig{'GEOIP_DB_FILE'} = $localGeoIPDB;
          &saveConfig($refConfig, $CONFIG_FILE);
        } else { $error = 1; $msg = "$$refSTR{'errorMsg'}: $$refSTR{'invalidFile'}"; }
      } else { $error = 1; $msg = "$$refSTR{'errorMsg'}: $GunzipError"; }
    } else { $error = 1; $msg = "$$refSTR{'errorMsg'}: $$refSTR{'errorDownload'}..."; }
    # Turn off progress bar
    $$refWin->ChangeCursor($$refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    # Final message
    if ($error) { return($msg); } # Error
    else        { return(0);    }
  } else {
    # Turn off progress bar
    $$refWin->ChangeCursor($$refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    return("$$refSTR{'errorMsg'}: $$refSTR{'errorDownload'}...");
  }
  $TOTAL_SIZE = 0;
  
}  #--- End downloadGeoIPDB

#--------------------------#
sub validXLWHOISDB
#--------------------------#
{
  # Local variables
  my $XLWHOISDBFile = shift;
  if (-f $XLWHOISDBFile) {
    # Connect to DB
    my $dsn = "DBI:SQLite:dbname=$XLWHOISDBFile";
    if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
      my $sth;
      eval { $sth = $dbh->table_info(undef, undef, '%', 'TABLE'); };
      return(0) if $@;
      # If table WHOIS_DB exists, database is valid
      my @info = $sth->fetchrow_array;
      $sth->finish();
      return(1) if $info[2] eq 'WHOIS_DB';
    }
  }
  return(0);
  
}  #--- End validXLWHOISDB

#--------------------------#
sub validIINDB
#--------------------------#
{
  # Local variables
  my $IINDBFile = shift;
  if (-f $IINDBFile) {
    # Connect to DB
    my $dsn = "DBI:SQLite:dbname=$IINDBFile";
    if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
      my $sth;
      eval { $sth = $dbh->table_info(undef, undef, '%', 'TABLE'); };
      return(0) if $@;
      # If table IIN exists, database is valid
      my @info = $sth->fetchrow_array;
      $sth->finish();
      return(1) if $info[2] eq 'IIN';
    }
  }
  return(0);
  
}  #--- End validIINDB

#--------------------------#
sub downloadIINDB
#--------------------------#
{
  # Local variables
  my ($localIINDB, $refHOURGLASS, $refARROW, $refWinConfig, $refConfig, $CONFIG_FILE, $refWinPb,
      $refWin, $refSTR) = @_;
  # Show progress window
  $$refWin->ChangeCursor($$refHOURGLASS);
  $$refWinPb->Text($$refSTR{'downloadIINDB'});
  $$refWinPb->lblPbCurr->Text($$refSTR{'connecting'}.' le-tools.com...');
  $$refWinPb->lblCount->Text("0 %");
  $$refWinPb->pbWinPb->SetRange(0, 100);
  $$refWinPb->pbWinPb->SetPos(0);
  $$refWinPb->pbWinPb->SetStep(1);
  $$refWinPb->Center($$refWin);
  $$refWinPb->Show();
  # Start an agent
  my $ua = new LWP::UserAgent;
  $ua->agent($$refConfig{'USERAGENT'});
  $ua->default_header('Accept-Language' => 'en');
  # Check size of the remote file
  my $req    = new HTTP::Request HEAD => $IINDB_URL;
  my $res    = $ua->request($req);
  my $return = $res->status_line;
  if ($res->code == 200) { $TOTAL_SIZE = $res->header('content_length'); }
  else {
    # Hide progress window
    $$refWin->ChangeCursor($refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    return("$$refSTR{'errorMsg'}: $$refSTR{'errorConRemote'}...");
  }
  # Download the file
  if ($TOTAL_SIZE) {
    my $downloadData;
    # Download the file
    $$refWinPb->lblPbCurr->Text($$refSTR{'downloadIINDB'}.'...');
    my $response = $ua->get($IINDB_URL, ':content_cb' => sub {
      # Local variables
      my ($data, $response, $protocol) = @_;
      $downloadData       .= $data;                                     # Downloaded data
      my $totalDownloaded  = length($downloadData);                     # Size of downloaded data
      my $completed        = int($totalDownloaded / $TOTAL_SIZE * 100); # Pourcentage of download completed
      $$refWinPb->pbWinPb->SetPos($completed);    # Set the progress bar
      $$refWinPb->lblCount->Text("$completed %"); # Indicate purcentage
    });
    # Save data in a temp file
    my $IINDB_ZIP = $localIINDB."\.zip";
    if ($response and $response->is_success) {
      open(ZIP,">$IINDB_ZIP");
      binmode(ZIP);
      print ZIP $downloadData;
      close(ZIP);
    } else {
      # Hide progress window
      $$refWin->ChangeCursor($refARROW);
      $$refWinPb->lblPbCurr->Text('');
      $$refWinPb->lblCount->Text('');
      $$refWinPb->pbWinPb->SetPos(0);
      $$refWinPb->Hide();
      return("$$refSTR{'errorMsg'}: $$refSTR{'errorConRemote'}...");
    }
    # Uncompress IINDB ZIP
    my ($error, $msg);
    if (-e $IINDB_ZIP) {
      $TOTAL_SIZE = 0;
      if (unzip $IINDB_ZIP => $localIINDB, BinModeOut => 1) {
        if (&validIINDB($localIINDB)) {
          unlink $IINDB_ZIP;
          $$refWinConfig->tfIINDB->Text($localIINDB);
          $$refConfig{'IIN_DB_FILE'} = $localIINDB;
          &saveConfig($refConfig, $CONFIG_FILE);
        } else { $error = 1; $msg = "$$refSTR{'errorMsg'}: $$refSTR{'invalidFile'}"; }
      } else { $error = 1; $msg = "$$refSTR{'errorMsg'}: $UnzipError"; }
    } else { $error = 1; $msg = "$$refSTR{'errorMsg'}: $$refSTR{'errorDownload'}..."; }
    # Turn off progress bar
    $$refWin->ChangeCursor($refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    # Final message
    if ($error) { return($msg); } # Error
    else        { return(0);    }
  } else {
    # Hide progress window
    $$refWin->ChangeCursor($refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    return("$$refSTR{'errorMsg'}: $$refSTR{'errorDownload'}...");
  }

}  #--- End downloadIINDB

#--------------------------#
sub createDTDB
#--------------------------#
{
  # Local variables
  my $DTDBFile = shift;
  # Create a new database
  my $dsn = "DBI:SQLite:dbname=$DTDBFile";
  my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 }) or return(0);
  # Create main table
  my $stmt = qq(CREATE TABLE IF NOT EXISTS DT
                (sample     VARCHAR(255)  NOT NULL,
                 pattern    VARCHAR(255)  NOT NULL,
                 regex      VARCHAR(255)  NOT NULL,
                 timezone   VARCHAR(255)          ,
                 use_as     INT                   ,
                 comment    VARCHAR(255)          ,
                 PRIMARY KEY (sample)));
  my $rv = $dbh->do($stmt);
  return(0) if $rv < 0;
  $dbh->disconnect();
  return(1);
  
}  #--- End createDTDB

#--------------------------#
sub loadDTDB
#--------------------------#
{
  # Local variables
  my ($refWinDTDB, $refWinConfig, $refWin, $refSTR) = @_;
  my $DTDBFile = $$refWinConfig->tfDTDB->Text();
  my @useAsStr = ($$refSTR{'input'}, $$refSTR{'output'}, $$refSTR{'both'}, $$refSTR{'none'});
  if (-f $DTDBFile) {
    my $dsn = "DBI:SQLite:dbname=$DTDBFile";
    my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })
              or Win32::GUI::MessageBox($$refWin, $$refSTR{'errorConnectDB'}.$DBI::errstr, $$refSTR{'error'}, 0x40010);
    # Check if DT table exists
    my $sth;
    eval { $sth = $dbh->table_info(undef, undef, '%', 'TABLE'); };
    if ($@) {
      Win32::GUI::MessageBox($$refWin, $$refSTR{'errorConnectDB'}.$DBI::errstr, $$refSTR{'error'}, 0x40010);
      return(0);
    }
    my @info = $sth->fetchrow_array;
    $sth->finish();
    if ($info[2] eq 'DT') { # If table DT exists, than load data
      my $all = $dbh->selectall_arrayref("SELECT * FROM DT ORDER BY sample ASC");
      # Database: table = DT, Fields = sample, pattern, regex, timezone, use_as, comment
      # Feed the grid
      my $i = 1;
      $$refWinDTDB->gridDT->SetRows(scalar(@$all)+1);
      foreach my $row (@$all) {
        my (@values) = @$row;
        $$refWinDTDB->gridDT->SetCellText($i, 0, $values[0]); # Sample
        $$refWinDTDB->gridDT->SetCellText($i, 1, $values[1]); # Pattern
        $$refWinDTDB->gridDT->SetCellText($i, 2, $values[2]); # Regex
        $$refWinDTDB->gridDT->SetCellText($i, 3, $values[3]) if $values[3] ne 'NULL'; # Timezone
        $$refWinDTDB->gridDT->SetCellText($i, 4, $useAsStr[$values[4]]);              # Use As
        $$refWinDTDB->gridDT->SetCellText($i, 5, $values[5]) if $values[5] ne 'NULL'; # Timezone
        $i++;
      }
      # Refresh grid
      $$refWinDTDB->gridDT->SortCells(1, 0, \&sortGridDT);
      $$refWinDTDB->gridDT->AutoSizeColumns();
      $$refWinDTDB->gridDT->ExpandColumnsToFit();
      $$refWinDTDB->gridDT->ScrollPos(1,0);
      $$refWinDTDB->gridDT->SetListMode();
      $dbh->disconnect();
      return(1);
    } else { Win32::GUI::MessageBox($$refWin, $$refSTR{'errorDB'}, $$refSTR{'error'}, 0x40010); return(0); }
  } else { return(0); }

}  #--- End loadDTDB

#--------------------------#
sub validDTDB
#--------------------------#
{
  # Local variables
  my $DTDBFile = shift;
  if (-f $DTDBFile) {
    # Connect to DB
    my $dsn = "DBI:SQLite:dbname=$DTDBFile";
    if (my $dbh = DBI->connect($dsn, undef, undef, { RaiseError => 1, AutoCommit => 1 })) {
      my $sth;
      eval { $sth = $dbh->table_info(undef, undef, '%', 'TABLE'); };
      return(0) if $@;
      # If table DT exists, database is valid
      my @info = $sth->fetchrow_array;
      $sth->finish();
      return(1) if $info[2] eq 'DT';
    }
  }
  return(0);
  
}  #--- End validDTDB

#--------------------------#
sub downloadDTDB
#--------------------------#
{
  # Local variables
  my ($localDTDB, $refHOURGLASS, $refARROW, $refWinDTDB, $refWinConfig, $refConfig, $CONFIG_FILE,
      $refWinPb, $refWin, $refSTR) = @_;
  # Show progress window
  $$refWin->ChangeCursor($$refHOURGLASS);
  $$refWinPb->Text($$refSTR{'downloadDTDB'});
  $$refWinPb->lblPbCurr->Text($$refSTR{'connecting'}.' le-tools.com...');
  $$refWinPb->lblCount->Text("0 %");
  $$refWinPb->pbWinPb->SetRange(0, 100);
  $$refWinPb->pbWinPb->SetPos(0);
  $$refWinPb->pbWinPb->SetStep(1);
  $$refWinPb->Center($$refWin);
  $$refWinPb->Show();
  # Start an agent
  my $ua = new LWP::UserAgent;
  $ua->agent($$refConfig{'USERAGENT'});
  $ua->default_header('Accept-Language' => 'en');
  # Check size of the remote file
  my $req    = new HTTP::Request HEAD => $DTDB_URL;
  my $res    = $ua->request($req);
  my $return = $res->status_line;
  if ($res->code == 200) { $TOTAL_SIZE = $res->header('content_length'); }
  else {
    # Hide progress window
    $$refWin->ChangeCursor($refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    return("$$refSTR{'errorMsg'}: $$refSTR{'errorConRemote'}...");
  }
  # Download the file
  if ($TOTAL_SIZE) {
    my $downloadData;
    # Download the file
    $$refWinPb->lblPbCurr->Text($$refSTR{'downloadDTDB'}.'...');
    my $response = $ua->get($DTDB_URL, ':content_cb' => sub {
      # Local variables
      my ($data, $response, $protocol) = @_;
      $downloadData       .= $data;                                     # Downloaded data
      my $totalDownloaded  = length($downloadData);                     # Size of downloaded data
      my $completed        = int($totalDownloaded / $TOTAL_SIZE * 100); # Pourcentage of download completed
      $$refWinPb->pbWinPb->SetPos($completed);    # Set the progress bar
      $$refWinPb->lblCount->Text("$completed %"); # Indicate purcentage
    });
    # Save data in a temp file
    my $DTDB_ZIP = $localDTDB."\.zip";
    if ($response and $response->is_success) {
      open(ZIP,">$DTDB_ZIP");
      binmode(ZIP);
      print ZIP $downloadData;
      close(ZIP);
    } else {
      # Hide progress window
      $$refWin->ChangeCursor($$refARROW);
      $$refWinPb->lblPbCurr->Text('');
      $$refWinPb->lblCount->Text('');
      $$refWinPb->pbWinPb->SetPos(0);
      $$refWinPb->Hide();
      return("$$refSTR{'errorMsg'}: $$refSTR{'errorConRemote'}...");
    }
    # Uncompress DTDB ZIP
    my ($error, $msg);
    if (-e $DTDB_ZIP) {
      $TOTAL_SIZE = 0;
      if (unzip $DTDB_ZIP => $localDTDB, BinModeOut => 1) {
        if (&validDTDB($localDTDB)) {
          unlink $DTDB_ZIP;
          $$refWinConfig->tfDTDB->Text($localDTDB);
          $$refConfig{'DT_DB_FILE'} = $localDTDB;
          &saveConfig($refConfig, $CONFIG_FILE);
          # Load the Datetime database
          &loadDTDB($refWinDTDB, $refWinConfig, $refWin, $refSTR);
          &cbInputDTFormatAddITems();
          $$refWin->cbInputDTFormat->SetCurSel(0);
          &cbOutputDTFormatAddITems();
          $$refWin->cbOutputDTFormat->SetCurSel(0);
          # Default output format
          if (exists($$refConfig{'DEFAULT_OUTPUT'})) { $$refWinDTDB->cbDefaultOutput->SetCurSel($$refConfig{'DEFAULT_OUTPUT'}); }
          else                                       { $$refWinDTDB->cbDefaultOutput->SetCurSel(0); }
        } else { $error = 1; $msg = "$$refSTR{'errorMsg'}: $$refSTR{'invalidFile'}"; }
      } else { $error = 1; $msg = "$$refSTR{'errorMsg'}: $UnzipError"; }
    } else { $error = 1; $msg = "$$refSTR{'errorMsg'}: $$refSTR{'errorDownload'}..."; }
    # Turn off progress bar
    $$refWin->ChangeCursor($$refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    # Final message
    if ($error) { return($msg); } # Error
    else        { return(0);    }
  } else {
    # Hide progress window
    $$refWin->ChangeCursor($$refARROW);
    $$refWinPb->lblPbCurr->Text('');
    $$refWinPb->lblCount->Text('');
    $$refWinPb->pbWinPb->SetPos(0);
    $$refWinPb->Hide();
    return("$$refSTR{'errorMsg'}: $$refSTR{'errorDownload'}...");
  }

}  #--- End downloadDTDB

#------------------------------------------------------------------------------#
1;