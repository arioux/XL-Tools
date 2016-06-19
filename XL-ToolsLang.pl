#!/usr/bin/perl
# Perl - v: 5.16.3
#------------------------------------------------------------------------------#
# XL-ToolsLang.pl : Strings for XL-Tools
# Website         : http://le-tools.com/
# GitHub		      : https://github.com/arioux/XL-Tools
# Creation        : 2015-12-21
# Modified        : 2016-04-08
# Author          : Alain Rioux (admin@le-tools.com)
#
# Copyright (C) 2015-2016  Alain Rioux (le-tools.com)
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

#------------------------------------------------------------------------------#
sub loadStr
#------------------------------------------------------------------------------#
{
  # Local variables
  my ($refSTR, $LANG_FILE) = @_;
  
  # Open and load string values
  open(LANG, "<:encoding(UTF-8)", $LANG_FILE);
  my @tab = <LANG>;
  close(LANG);
  
  # Store values  
  foreach (@tab) {
    chomp($_);
    s/[^\w\=\s\.\!\,\-\)\(\']//g;
    my ($key, $value) = split(/ = /, $_);
    $value = encode("iso-8859-1", $value); # Revaluate with different language encoding
    if ($key) { $$refSTR{$key}  = $value; }
  }
  
}  #--- End loadStr

#------------------------------------------------------------------------------#
sub loadDefaultStr
#------------------------------------------------------------------------------#
{
  # Local variables
  my $refSTR = shift;
  
  # Set default strings
  
  # General strings
  $$refSTR{'use'}             = 'Use';
  $$refSTR{'cancel'}          = 'Cancel';
  $$refSTR{'about'}           = 'About';
  $$refSTR{'text'}            = 'Text file';
  $$refSTR{'dbFile'}          = 'Database file';
  $$refSTR{'selectFile'}      = 'Select file';
  $$refSTR{'useFile'}         = 'Use file';
  $$refSTR{'startingProcess'} = 'Starting process';
  $$refSTR{'runningProcess'}  = 'Running process';
  $$refSTR{'connecting'}      = 'Connecting to';
  $$refSTR{'saveToFile'}      = 'Save to a file';
  $$refSTR{'saveToFileMsg'}   = 'Not enough space to write results in textfield. Do you wish to save the results in a file ?';
  $$refSTR{'monday'}          = 'Monday';
  $$refSTR{'tuesday'}         = 'Tuesday';
  $$refSTR{'wednesday'}       = 'Wednesday';
  $$refSTR{'thursday'}        = 'Thursday';
  $$refSTR{'friday'}          = 'Friday';
  $$refSTR{'saturday'}        = 'Saturday';
  $$refSTR{'sunday'}          = 'Sunday';
  $$refSTR{'country'}         = 'Country';
  $$refSTR{'countryCode'}     = 'Country code';
  $$refSTR{'region'}          = 'Region';
  $$refSTR{'regionCode'}      = 'Region code';
  $$refSTR{'city'}            = 'City';
  $$refSTR{'postalCode'}      = 'Postal code';
  $$refSTR{'GPScoord'}        = 'GPS coordinates';
  $$refSTR{'tzName'}          = 'Timezone name';
  $$refSTR{'tzOffset'}        = 'Timezone offset';
  $$refSTR{'uaType'}          = 'Type';
  $$refSTR{'uaOS'}            = 'OS';
  $$refSTR{'uaBrowser'}       = 'Browser';
  $$refSTR{'uaDevice'}        = 'Device';
  $$refSTR{'uaLang'}          = 'Lang';
  $$refSTR{'brand'}           = 'Brand';
  $$refSTR{'subBrand'}        = 'Sub Brand';
  $$refSTR{'bank'}            = 'Bank';
  $$refSTR{'cardType'}        = 'Card Type';
  $$refSTR{'cardCategory'}    = 'Card Category';
  $$refSTR{'countryName'}     = 'Country Name';
  
  # Error
  $$refSTR{'error'}           = 'Error';
  $$refSTR{'formatNotFound'}  = 'Format not found';
  $$refSTR{'invalidFile'}     = 'File is invalid';
  $$refSTR{'errorReading'}    = 'Error reading';
  $$refSTR{'errorOpening'}    = 'Error opening';
  $$refSTR{'errorWriting'}    = 'Error writing';
  $$refSTR{'errorConnecting'} = 'Error connecting';
  $$refSTR{'warning'}         = 'Warning';
  $$refSTR{'maxSizeReached'}  = 'Maximum number of characters has been reached. Your text may have been truncated.';
  $$refSTR{'processRunning'}  = 'A process is already running. Wait until it stops or restart the program.';
  $$refSTR{'errorMsg'}        = 'Error messsage';
  $$refSTR{'errDoc'}          = 'Documentation.chm have not been found in the program folder.';
  $$refSTR{'noInput'}         = 'No input';
  $$refSTR{'errorConversion'} = 'Conversion error';
  $$refSTR{'errorConnection'} = 'Connection error';
  $$refSTR{'invalidInput'}    = 'Invalid input';
  $$refSTR{'noMatch'}         = 'No match';
  $$refSTR{'errorConnectDB'}  = 'Error connecting to database';
  $$refSTR{'errorConRemote'}  = 'Error connecting to remote site';
  $$refSTR{'errorDownload'}   = 'Error downloading the database';
  $$refSTR{'errorCreatingDB'} = 'Error creating the database';
  $$refSTR{'selectedCF'}      = 'Selected custom function';
  $$refSTR{'unknownError'}    = 'Unknown error';
  $$refSTR{'errorOUI_TXT'}    = 'Error with oui.txt file';
  $$refSTR{'errRegex'}        = 'You must enter a valid regex.';
  $$refSTR{'errBy'}           = 'You must enter a valid replacement expression.';
  $$refSTR{'errRegexReplace'}   = 'Current error in * Replace *';
  $$refSTR{'errRegexReplaceBy'} = 'Current error in * By *';

  # Main Window
  $$refSTR{'Tab1'}          = 'Lists';
  $$refSTR{'Tab2'}          = 'Sorting';
  $$refSTR{'Tab3'}          = 'Conversion';
  $$refSTR{'Tab4'}          = 'Time';
  $$refSTR{'Tab5'}          = 'Utils';
  $$refSTR{'InputFormat'}   = 'Input format';
  $$refSTR{'btnGuess'}      = 'Guess';
  $$refSTR{'btnGuessTip'}   = 'Use this function only if date and time format is the same for each item in the list.';
  $$refSTR{'MatchCase'}     = 'Match case';
  $$refSTR{'Regex'}         = 'Regex';
  $$refSTR{'Eval'}          = 'Eval';
  $$refSTR{'ResetContent'}  = 'Reset content';
  $$refSTR{'Results'}       = 'Results';
  $$refSTR{'ViewReport'}    = 'View the report';
  $$refSTR{'lblNotReady'}   = 'Not Ready ? Click here';
  $$refSTR{'notReady'}      = 'Not ready';
  $$refSTR{'nextStep'}      = 'Next step';
  $$refSTR{'insertList1'}   = 'Insert items in List 1.';
  $$refSTR{'insertLists'}   = 'Insert items in List 1 or in List 2.';
  $$refSTR{'insertWith'}    = 'Insert a value in With textfield. See documentation about this function.';
  $$refSTR{'insertReplace'} = 'Insert value in Replace textfield. See documentation about this function.';
  $$refSTR{'insertSameNbr'} = 'You must insert the same number of items in both List 1 and List 2.';
  $$refSTR{'insertMACOUI'}  = 'You must have a valid MACOUI database to use this function. See documentation.';
  $$refSTR{'insertGeoIP'}   = 'You must have a valid GeoIP database to use this function. See documentation.';
  $$refSTR{'insertXLWhois'} = 'You must have a valid XL-Whois database to use this function. See documentation.';
  $$refSTR{'insertIIN'}     = 'You must have a valid IIN database to use this function. See documentation.';
  $$refSTR{'selectFunc'}    = 'You must select a function.';
  $$refSTR{'Process'}       = 'Process';
  $$refSTR{'StopProcess'}   = 'Stop process';
  $$refSTR{'Configuration'} = 'Open Settings Window';
  $$refSTR{'btnHelpTip'}    = 'See Documentation';

  # Lists Tab
  $$refSTR{'cbLists1'}      = 'No duplicate';
  $$refSTR{'cbLists2'}      = 'Only duplicates';
  $$refSTR{'cbLists3'}      = 'Count items';
  $$refSTR{'cbLists4'}      = 'Count characters';
  $$refSTR{'cbLists5'}      = 'L1-L2';
  $$refSTR{'cbLists6'}      = 'Column to row';
  $$refSTR{'cbLists7'}      = 'Row to column';
  $$refSTR{'cbLists8'}      = 'List to regex';
  $$refSTR{'cbLists9'}      = 'Concat';
  $$refSTR{'cbLists10'}     = 'Split strings';
  $$refSTR{'cbLists11'}     = 'Split and extract';
  $$refSTR{'cbLists12'}     = 'Merge lines';
  $$refSTR{'cbLists13'}     = 'Replace';
  $$refSTR{'cbLists14'}     = 'Reverse string';
  $$refSTR{'cbLists15'}     = 'Lowercase';
  $$refSTR{'cbLists16'}     = 'Uppercase';
  $$refSTR{'cbLists17'}     = 'Add line number';
  $$refSTR{'MatchSpace'}    = 'Ignore space';
  $$refSTR{'With'}          = 'With';
  $$refSTR{'Columns'}       = 'Columns';
  $$refSTR{'Replace'}       = 'Replace';
  $$refSTR{'By'}            = 'By';
  $$refSTR{'all'}           = 'All characters';
  $$refSTR{'firstOnly'}     = 'First only';
  $$refSTR{'firstEachWord'} = 'First of each word';
  
  # Sort Tab
  $$refSTR{'cbSorts1'}      = 'Alphabetical order';
  $$refSTR{'cbSorts2'}      = 'Numerical order';
  $$refSTR{'cbSorts3'}      = 'String length';
  $$refSTR{'cbSorts4'}      = 'IPv4 Address';
  $$refSTR{'cbSorts5'}      = 'Date and time';
  $$refSTR{'Ascending'}     = 'Ascending';
  $$refSTR{'Descending'}    = 'Descending';
  
  # Conversion Tab
  $$refSTR{'cbConv1'}       = 'Hex to ASCII';
  $$refSTR{'cbConv2'}       = 'ASCII to Hex';
  $$refSTR{'cbConv3'}       = 'Hex to Base10';
  $$refSTR{'cbConv4'}       = 'Base10 to ASCII';
  $$refSTR{'cbConv5'}       = 'URI Decode';
  $$refSTR{'cbConv6'}       = 'URI Encode';
  $$refSTR{'cbConv7'}       = 'HTML Decode';
  $$refSTR{'cbConv8'}       = 'HTML Encode';
  $$refSTR{'cbConv9'}       = 'Base64 to ASCII';
  $$refSTR{'cbConv10'}      = 'ASCII to Base64';
  $$refSTR{'cbConv11'}      = 'SHA1 - Base32 to Base16';
  
  # Time Tab
  $$refSTR{'cbTime1'}       = 'Anytime to Anytime';
  $$refSTR{'cbTime2'}       = 'Unixtime to Anytime';
  $$refSTR{'cbTime3'}       = 'ChromeTime to Anytime';
  $$refSTR{'cbTime4'}       = 'LDAPTime to Anytime';
  $$refSTR{'cbTime5'}       = 'Anytime to Unixtime';
  $$refSTR{'cbTime6'}       = 'Date to Weekday';
  $$refSTR{'cbTime7'}       = 'Time difference';
  $$refSTR{'cbTime8'}       = 'Add time';
  $$refSTR{'cbTime9'}       = 'Substract time';  
  $$refSTR{'Local'}         = 'Local';  
  $$refSTR{'GMT'}           = 'GMT';  
  $$refSTR{'Other'}         = 'Other';
  $$refSTR{'SingleDate'}    = 'Use a single date';  
  $$refSTR{'Dur'}           = 'Dur';
  $$refSTR{'years'}         = 'years';
  $$refSTR{'months'}        = 'months';
  $$refSTR{'days'}          = 'days';
  $$refSTR{'hours'}         = 'hours';
  $$refSTR{'minutes'}       = 'minutes';
  $$refSTR{'seconds'}       = 'seconds';
  
  # Utils Tab
  $$refSTR{'cbUtils1'}      = 'NSLookup';
  $$refSTR{'cbUtils2'}      = 'CIDR to IP Range';
  $$refSTR{'cbUtils3'}      = 'IP Range to CIDR';
  $$refSTR{'cbUtils4'}      = 'CIDR to IP list';
  $$refSTR{'cbUtils5'}      = 'IP to Arpa';
  $$refSTR{'cbUtils6'}      = 'Arpa to IP';
  $$refSTR{'cbUtils7'}      = 'Resolve MAC Address';
  $$refSTR{'cbUtils8'}      = 'Resolve IPv4 GeoIP';
  $$refSTR{'cbUtils9'}      = 'Resolve ISP';
  $$refSTR{'cbUtils10'}     = 'Resolve User-agent';
  $$refSTR{'cbUtils11'}     = 'Credit Card to Issuing Company';
  $$refSTR{'cbUtils12'}     = 'Custom functions...';
  $$refSTR{'GeoIPOpt1'}     = 'All available';
  $$refSTR{'GeoIPOpt2'}     = 'Country';
  $$refSTR{'GeoIPOpt3'}     = 'Country code';
  $$refSTR{'GeoIPOpt4'}     = 'Region';
  $$refSTR{'GeoIPOpt5'}     = 'Region code';
  $$refSTR{'GeoIPOpt6'}     = 'City';
  $$refSTR{'GeoIPOpt7'}     = 'Postal code';
  $$refSTR{'GeoIPOpt8'}     = 'GPS coordinates';
  $$refSTR{'GeoIPOpt9'}     = 'Timezone name';
  $$refSTR{'GeoIPOpt10'}    = 'Timezone offset';
  $$refSTR{'Addheaders'}    = 'Add headers';
  $$refSTR{'UAOpt1'}        = 'All available';
  $$refSTR{'UAOpt2'}        = 'Type';
  $$refSTR{'UAOpt3'}        = 'OS';
  $$refSTR{'UAOpt4'}        = 'Browser';
  $$refSTR{'UAOpt5'}        = 'Device';
  $$refSTR{'UAOpt6'}        = 'Lang';
  $$refSTR{'IINLocalDB'}    = 'Use local IIN DB';
  $$refSTR{'IINLocalDBTip'} = 'Faster, but less accurate.';
  $$refSTR{'BinlistTip'}    = 'Slower, but more accurate, max. 1000 queries per hour.';
  $$refSTR{'cbCFLists'}     = 'Select a function';
  $$refSTR{'btnCFAdd'}      = 'Add a custom function database';
  $$refSTR{'btnCFRem'}      = 'Remove the selected custom function';
  $$refSTR{'btnCFEdit'}     = 'Edit the selected custom function';
  $$refSTR{'btnCFNew'}      = 'Create a new custom function';
  $$refSTR{'Title'}         = 'Title';
  $$refSTR{'btnCFSave'}     = 'Save to database';
  $$refSTR{'btnCFCancel'}   = 'Cancel operation';
  $$refSTR{'funcAdded'}     = 'Function have been added.';
  $$refSTR{'funcExists'}    = 'Title of the function already exists. You must change it.';
  $$refSTR{'funcNoTitle'}   = 'No title in the database';
  $$refSTR{'remConfirmT'}   = 'Confirm removal';
  $$refSTR{'remConfirm'}    = 'Are you sure you want to remove the';
  $$refSTR{'func'}          = 'function';
  $$refSTR{'delConfirm'}    = 'Function removed. Do you want the delete the file';
  $$refSTR{'delConfirmT'}   = 'Confirm deletion';
  $$refSTR{'funcDeleted'}   = 'The file have been deleted.';
  $$refSTR{'CFErrorDupl'}   = 'List 1 must not contain duplicates.';
  $$refSTR{'funcExists2'}   = 'Function already exists. Replace data';
  $$refSTR{'replConfirmT'}  = 'Confirm replacement';

  # Config Window
  $$refSTR{'winConfig'}       = 'Settings';
  $$refSTR{'general'}         = 'General';
  $$refSTR{'database'}        = 'Databases';
  $$refSTR{'AutoUpdateTip'}   = 'Check for update at startup';
  $$refSTR{'selectDBFile'}    = 'Select the database file';
  $$refSTR{'downloadDB'}      = 'Download the database';
  $$refSTR{'firstStart'}      = 'This is your first use of XL-Tools. Do you want to set default configuration ?';
  $$refSTR{'defaultDir'}      = 'Do you want to use default dir';
  $$refSTR{'selectFolder'}    = 'Select a folder';
  $$refSTR{'SetGenOpt'}       = 'Set General Options';
  $$refSTR{'winPb'}           = 'Progress';
  $$refSTR{'winCW'}           = 'Configuration Wizard';
  $$refSTR{'configSet'}       = 'XL-Tool has been configured !';
  $$refSTR{'configSetPart'}   = 'Aborted ! XL-Tool has been partially configured.';
  # General tab
  $$refSTR{'Tool'}            = 'Tool';
  $$refSTR{'Export'}          = 'Export';
  $$refSTR{'checkUpdate'}     = 'Check Update';
  $$refSTR{'update1'}         = 'You have the latest version installed.';
  $$refSTR{'update2'}         = 'Check for update';
  $$refSTR{'update3'}         = 'Update';
  $$refSTR{'update4'}         = 'Version';
  $$refSTR{'update5'}         = 'is available. Download it';
  $$refSTR{'OptFunctions'}    = 'Functions';
  $$refSTR{'chFullScreen'}    = 'Start Full Screen';
  $$refSTR{'chRememberPos'}   = 'Remember position';
  $$refSTR{'MaxSize'}         = 'Max size (List)';
  $$refSTR{'chars'}           = 'chars';
  $$refSTR{'NsLookupTO1'}     = 'Nslookup timeout';
  $$refSTR{'UserAgent'}       = 'User-Agent';
  $$refSTR{'NoResultOpt'}     = 'When no result';
  $$refSTR{'NoResultOpt1'}    = 'Leave a blank';
  $$refSTR{'NoResultOpt1Tip'} = 'When a function gives no result, leave a blank.';
  $$refSTR{'NoResultOpt2'}    = 'Show status';
  $$refSTR{'NoResultOpt2Tip'} = 'Write the reason why there is no result (error, no match, etc.).';
  # Database tab
  $$refSTR{'OUIDB'}           = 'OUI DB';
  $$refSTR{'importOUIDB'}     = 'Import OUI Database';
  $$refSTR{'importedOUIDB'}   = 'OUI Database successfully imported !';
  $$refSTR{'GeoIPDB'}         = 'GeoIP DB';
  $$refSTR{'XLWhoisDB'}       = 'XL-Whois DB';
  $$refSTR{'IINLocalDB'}      = 'IIN Local DB';
  $$refSTR{'locXLWhoisDB'}    = 'Locate the XL-Whois DB';
  $$refSTR{'locIINLocalDB'}   = 'Locate the IIN Local DB';
  $$refSTR{'selMACOUIFile'}   = 'Select the MAC OUI Database file';
  $$refSTR{'selPathDB'}       = 'Select the path for the database';
  $$refSTR{'selGeoIPFile'}    = 'Select the GeoIP Database file';
  $$refSTR{'currDBDate'}      = 'Current DB date';
  $$refSTR{'remoteDBDate'}    = 'DB date on';
  $$refSTR{'updateAvailable'} = 'An update of the database is available, download';
  $$refSTR{'DBUpToDate'}      = 'Your database is up to date';
  $$refSTR{'createDBTable'}   = 'Create database and table';
  $$refSTR{'uptMACOUI'}       = 'Update MAC OUI Database';
  $$refSTR{'updatedMACOUI'}   = 'The MACOUI database has been updated';
  $$refSTR{'checkMACOUIUpt'}  = 'Check update for the MAC OUI Database';
  $$refSTR{'MACOUINotExist'}  = 'The MAC OUI database (oui.db) does not exist, download';
  $$refSTR{'downloadMACOUI'}  = 'Downloading MAC OUI Database';
  $$refSTR{'convertMACOUI'}   = 'Convert MAC OUI Database';
  $$refSTR{'uptGeoIP'}        = 'Update GeoIP Database';
  $$refSTR{'updatedGeoIP'}    = 'The GeoIP database has been updated';
  $$refSTR{'checkGeoIPUpt'}   = 'Check update for the GeoIP Database';
  $$refSTR{'GeoIPNotExist'}   = 'The GeoIP database (GeoLiteCity.dat) does not exist, download';
  $$refSTR{'downloadGeoIP'}   = 'Downloading GeoIP Database';
  $$refSTR{'downloadWarning'} = 'It may take a few minutes';
  
  # About Window
  $$refSTR{'version'}         = 'Version';
  $$refSTR{'author'}          = 'Author';
  $$refSTR{'translatedBy'}    = 'Translated by';
  $$refSTR{'website'}         = 'Website';
  $$refSTR{'translatorName'}  = '-';


}  #--- End loadStrings


#------------------------------------------------------------------------------#
1;