#!/usr/bin/perl
# Perl - v: 5.16.3
#------------------------------------------------------------------------------#
# XL-ToolsLang.pl : Strings for XL-Tools
# WebSite         : http://le-tools.com/XL-Tools.html
# SourceForge     : https://sourceforge.net/p/xl-tools
# GitHub          : https://github.com/arioux/XL-Tools
# Documentation   : http://le-tools.com/XL-ToolsDoc.html
# Creation        : 2015-12-21
# Modified        : 2019-11-10
# Author          : Alain Rioux (admin@le-tools.com)
#
# Copyright (C) 2015-2019  Alain Rioux (le-tools.com)
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
    $value            = encode("iso-8859-1", $value); # Revaluate with different language encoding
    $$refSTR{$key}    = $value if $key;
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
  $$refSTR{'Cancel'}          = 'Cancel';
  $$refSTR{'About'}           = 'About';
  $$refSTR{'text'}            = 'Text file';
  $$refSTR{'dbFile'}          = 'Database file';
  $$refSTR{'selectFile'}      = 'Select file';
  $$refSTR{'useFile'}         = 'Use file';
  $$refSTR{'Download'}        = 'Download';
  $$refSTR{'startingProcess'} = 'Starting process';
  $$refSTR{'runningProcess'}  = 'Running process';
  $$refSTR{'Connecting'}      = 'Connecting to';
  $$refSTR{'Downloading'}     = 'Downloading';
  $$refSTR{'Inserting'}       = 'Inserting';
  $$refSTR{'saveToFile'}      = 'Save to a file';
  $$refSTR{'saveToFileMsg'}   = 'Not enough space to write results in textfield. Do you wish to save the results in a file?';
  $$refSTR{'Type'}            = 'Type';
  $$refSTR{'Language'}        = 'Language';
  $$refSTR{'Continent'}       = 'Continent';
  $$refSTR{'Country'}         = 'Country';
  $$refSTR{'countryCode'}     = 'Country code';
  $$refSTR{'Region'}          = 'Region';
  $$refSTR{'regionCode'}      = 'Region code';
  $$refSTR{'City'}            = 'City';
  $$refSTR{'postalCode'}      = 'Postal code';
  $$refSTR{'GPScoord'}        = 'GPS coordinates';
  $$refSTR{'tzName'}          = 'Timezone name';
  $$refSTR{'tzOffset'}        = 'Timezone offset';
  $$refSTR{'uaOS'}            = 'OS';
  $$refSTR{'uaBrowser'}       = 'Browser';
  $$refSTR{'uaDevice'}        = 'Device';
  $$refSTR{'uaLang'}          = 'Lang';
  $$refSTR{'Brand'}           = 'Brand';
  $$refSTR{'Prepaid'}         = 'Prepaid';
  $$refSTR{'BankName'}        = 'Bank name';
  $$refSTR{'BankUrl'}         = 'Bank url';
  $$refSTR{'BankPhone'}       = 'Bank phone';
  $$refSTR{'BankCity'}        = 'Bank city';
  $$refSTR{'Save'}            = 'Save';
  # Error
  $$refSTR{'Error'}           = 'Error';
  $$refSTR{'formatNotFound'}  = 'Format not found';
  $$refSTR{'invalidFile'}     = 'File is invalid';
  $$refSTR{'errorReading'}    = 'Error reading';
  $$refSTR{'errorOpening'}    = 'Error opening';
  $$refSTR{'errorWriting'}    = 'Error writing';
  $$refSTR{'Warning'}         = 'Warning';
  $$refSTR{'maxSizeReached'}  = 'Maximum number of characters has been reached. Your text may have been truncated.';
  $$refSTR{'processRunning'}  = 'A process is already running. Wait until it stops or restart the program.';
  $$refSTR{'errorMsg'}        = 'Error messsage';
  $$refSTR{'noInput'}         = 'No input';
  $$refSTR{'errorConversion'} = 'Conversion error';
  $$refSTR{'errorConnection'} = 'Connection error';
  $$refSTR{'invalidInput'}    = 'Invalid input';
  $$refSTR{'noMatch'}         = 'No match';
  $$refSTR{'errorDB'}         = 'Error database';
  $$refSTR{'errorConnectDB'}  = 'Error connecting to database';
  $$refSTR{'errorConRemote'}  = 'Error connecting to remote site';
  $$refSTR{'errorDownload'}   = 'Error downloading';
  $$refSTR{'errorCreatingDB'} = 'Error creating the database';
  $$refSTR{'errorUnzip'}      = 'Error uncompressing file';
  $$refSTR{'selectedCF'}      = 'Selected custom function';
  $$refSTR{'unknownError'}    = 'Unknown error';
  $$refSTR{'errorOUI_TXT'}    = 'Error with oui.txt file';
  $$refSTR{'errRegex'}        = 'You must enter a valid regex.';
  $$refSTR{'errBy'}           = 'You must enter a valid replacement expression.';
  $$refSTR{'errRegexReplace'}   = 'Current error in * Replace *';
  $$refSTR{'errRegexReplaceBy'} = 'Current error in * By *';
  $$refSTR{'errNewLine'}        = 'Error creating new line in grid.';
  # Main Window
  $$refSTR{'Tab1'}          = 'Lists';
  $$refSTR{'Tab2'}          = 'Sorting';
  $$refSTR{'Tab3'}          = 'Conversion';
  $$refSTR{'Tab4'}          = 'Time';
  $$refSTR{'Tab5'}          = 'Utils';
  $$refSTR{'MatchCase'}     = 'Match case';
  $$refSTR{'Regex'}         = 'Regex';
  $$refSTR{'Eval'}          = 'Eval';
  $$refSTR{'ResetContent'}  = 'Reset content';
  $$refSTR{'btnList1UseRes'} = 'Copy data from results';
  $$refSTR{'Results'}       = 'Results';
  $$refSTR{'resInFile'}     = 'Use file';
  $$refSTR{'ViewReport'}    = 'View the report';
  $$refSTR{'lblNotReady'}   = 'Not Ready? Click here';
  $$refSTR{'notReady'}      = 'Not ready';
  $$refSTR{'nextStep'}      = 'Next step';
  $$refSTR{'insertList1'}   = 'Insert items in List 1.';
  $$refSTR{'insertLists'}   = 'Insert items in List 1 or in List 2.';
  $$refSTR{'insertWith'}    = 'Insert a value in With textfield.';
  $$refSTR{'insertColumns'} = 'Insert a value in Columns textfield.';
  $$refSTR{'insertReplace'} = 'Insert a value in Replace textfield.';
  $$refSTR{'seeDoc'}        = 'See documentation.';
  $$refSTR{'insertSameNbr'} = 'You must insert the same number of items in both List 1 and List 2.';
  $$refSTR{'setOutputFormat'} = 'You must select a different output format for this input type.';
  $$refSTR{'validDB1'}      = 'You must have a valid';
  $$refSTR{'validDB2'}      = 'to use this function.';
  $$refSTR{'selectFunc'}    = 'You must select a function.';
  $$refSTR{'Process'}       = 'Process';
  $$refSTR{'StopProcess'}   = 'Stop process';
  $$refSTR{'Configuration'} = 'Open Settings Window';
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
  $$refSTR{'cbLists19'}     = 'Split and merge';
  $$refSTR{'cbLists13'}     = 'Replace';
  $$refSTR{'cbLists14'}     = 'Reverse string';
  $$refSTR{'cbLists15'}     = 'Lowercase';
  $$refSTR{'cbLists16'}     = 'Uppercase';
  $$refSTR{'cbLists17'}     = 'Add line number';
  $$refSTR{'cbLists18'}     = 'Transliterate';
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
  $$refSTR{'cbSorts6'}      = 'Randomize';
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
  $$refSTR{'cbConv12'}      = 'SHA1 - Base16 to Base32';
  # Time Tab
  $$refSTR{'cbTime1'}       = 'Anytime to Anytime';
  $$refSTR{'cbTime2'}       = 'Time difference';
  $$refSTR{'cbTime3'}       = 'Add time';
  $$refSTR{'cbTime4'}       = 'Substract time';
  $$refSTR{'lblDTParser'}   = 'Parse context';
  $$refSTR{'Before'}        = 'Before';
  $$refSTR{'After'}         = 'After';
  $$refSTR{'Input'}         = 'Input';
  $$refSTR{'Open'}          = 'Open';
  $$refSTR{'Datetime'}      = 'Datetime';
  $$refSTR{'chromeTime'}    = 'ChromeTime';
  $$refSTR{'LDAPTime'}      = 'LDAPTime';
  $$refSTR{'Filetime'}      = 'Filetime';
  $$refSTR{'SystemTime'}    = 'SystemTime';
  $$refSTR{'MacAbsTime'}    = 'Mac Absolute time';
  $$refSTR{'MacHFS'}        = 'Mac HFS+';
  $$refSTR{'btnInputFormatGuessTip'} = 'Use the first item to guess the format';
  $$refSTR{'Output'}        = 'Output';
  $$refSTR{'btnOutputFormatTip'} = 'Set a format for the output';
  $$refSTR{'Local'}         = 'Local';  
  $$refSTR{'UTC'}           = 'UTC';  
  $$refSTR{'Other'}         = 'Other';
  $$refSTR{'SingleDate'}    = 'Use a single date';  
  $$refSTR{'Dur'}           = 'Dur';
  $$refSTR{'string'}        = 'string';
  $$refSTR{'years'}         = 'years';
  $$refSTR{'months'}        = 'months';
  $$refSTR{'days'}          = 'days';
  $$refSTR{'weeks'}         = 'weeks';
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
  $$refSTR{'cbUtils8'}      = 'Resolve GeoIP';
  $$refSTR{'cbUtils9'}      = 'Resolve ISP';
  $$refSTR{'cbUtils10'}     = 'Resolve User-agent';
  $$refSTR{'cbUtils11'}     = 'Credit Card to Issuing Company';
  $$refSTR{'cbUtils13'}     = 'Address to GPS';
  $$refSTR{'cbUtils15'}     = 'GPS to address';
  $$refSTR{'cbUtils14'}     = 'Distance between locations';
  $$refSTR{'cbUtils12'}     = 'Custom functions...';
  $$refSTR{'AllDetails'}    = 'All details';
  $$refSTR{'Addheaders'}    = 'Add headers';
  $$refSTR{'checkOpt'}      = 'You must check at least one detail';
  $$refSTR{'IINLocalDB'}    = 'Use local IIN DB';
  $$refSTR{'IINLocalDBTip'} = 'Faster, but less accurate.';
  $$refSTR{'BinlistTip'}    = 'Slower, but more accurate, max. 1000 queries per hour.';
  $$refSTR{'cbCFLists'}     = 'Select a function';
  $$refSTR{'emailRequired'} = 'A valid email is required when you do many requests. See config.';
  $$refSTR{'incAddr'}       = 'Include full address in result';
  $$refSTR{'ZoomLevel'}     = 'Zoom level';
  $$refSTR{'ZoomLevel3'}    = 'Country'; # 3
  $$refSTR{'ZoomLevel5'}    = 'State'; # 5
  $$refSTR{'ZoomLevel8'}    = 'County'; # 8
  $$refSTR{'ZoomLevel10'}   = 'City'; # 10
  $$refSTR{'ZoomLevel14'}   = 'Suburb'; # 14
  $$refSTR{'ZoomLevel16'}   = 'Major streets'; # 16
  $$refSTR{'ZoomLevel17'}   = 'Major/minor streets'; # 17
  $$refSTR{'ZoomLevel18'}   = 'Building'; # 18
  $$refSTR{'FullAddress'}   = 'Full address';
  $$refSTR{'AddressEl'}     = 'Address elements';
  $$refSTR{'house_number'}  = 'house_number';
  $$refSTR{'road'}          = 'road';
  $$refSTR{'neighbourhood'} = 'neighbourhood';
  $$refSTR{'suburb'}        = 'suburb';
  $$refSTR{'city'}          = 'city';
  $$refSTR{'county'}        = 'county';
  $$refSTR{'region'}        = 'region';
  $$refSTR{'state'}         = 'state';
  $$refSTR{'postcode'}      = 'postcode';
  $$refSTR{'country'}       = 'country';
  $$refSTR{'country_code'}  = 'country_code';
  $$refSTR{'boundingbox'}   = 'boundingbox';
  $$refSTR{'chSingleLocation'} = 'Compare to single location';
  $$refSTR{'reqLocation'}   = 'You must enter a location to compare to.';
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
  # Datetime database Window
  $$refSTR{'DTDB'}            = 'Datetime database';
  $$refSTR{'btnDTAdd'}        = 'Add a new datetime format';
  $$refSTR{'btnDTEdit'}       = 'Edit the selected datetime format';
  $$refSTR{'btnDTDel'}        = 'Remove the selected datetime format';
  $$refSTR{'sample'}          = 'Sample';
  $$refSTR{'pattern'}         = 'Pattern';
  $$refSTR{'useAs'}           = 'Use as';
  $$refSTR{'comment'}         = 'Comment';  
  $$refSTR{'timezone'}        = 'Timezone';
  $$refSTR{'defaultOutput'}   = 'Default output';
  $$refSTR{'guess'}           = 'Guess';
  $$refSTR{'guessORVar'}      = 'Guess (or variable)';
  $$refSTR{'default'}         = 'Default';
  $$refSTR{'same'}            = 'Same as input';
  $$refSTR{'formatFound'}     = 'Format found';
  $$refSTR{'formatMatch'}     = 'Format match';
  $$refSTR{'addedDTObj'}      = 'Datetime object has been added!';
  $$refSTR{'updatedDTObj'}    = 'Datetime object has been updated!';
  $$refSTR{'deletedDTObj'}    = 'Datetime object has been deleted!';
  # Datetime object Window
  $$refSTR{'winDTObj'}        = 'Datetime object';
  $$refSTR{'useFirst'}        = 'From List 1';
  $$refSTR{'useFirstTip'}     = 'Use first item of List 1';
  # Pattern
  $$refSTR{'pattern1'}        = '%B - Full month name (ex.: January)';
  $$refSTR{'pattern2'}        = '%b - Abbreviated month name (ex.: Jan)';
  $$refSTR{'pattern3'}        = '%D - Equivalent to %m/%d/%y';
  $$refSTR{'pattern4'}        = '%d - Day of the month (01-31)';
  $$refSTR{'pattern5'}        = '%e - Day of the month (1-31)';
  $$refSTR{'pattern6'}        = '%F - Equivalent to %Y-%m-%d';
  $$refSTR{'pattern7'}        = '%H - Hour 24H (00-23)';
  $$refSTR{'pattern8'}        = '%I - Hour 12H (01-12)';
  $$refSTR{'pattern9'}        = '%M - Minute (00-59)';
  $$refSTR{'pattern10'}       = '%m - Month (01-12)';
  $$refSTR{'pattern11'}       = '%p - AM or PM';
  $$refSTR{'pattern12'}       = '%R - Equivalent to %H:%M';
  $$refSTR{'pattern13'}       = '%r - Equivalent to %I:%M:%S %p';
  $$refSTR{'pattern14'}       = '%S - Second (00-60)';
  $$refSTR{'pattern15'}       = '%T - Equivalent to %H:%M:%S';
  $$refSTR{'pattern16'}       = '%v - Equivalent to %e-%b-%Y';
  $$refSTR{'pattern17'}       = '%w - Weekday (0-6)';
  $$refSTR{'pattern18'}       = '%Y - Year 4-digits (Ex.: 2016)';
  $$refSTR{'pattern19'}       = '%y - Year 2-digits (Ex.: 16)';
  $$refSTR{'pattern20'}       = '%Z - Time zone name (UTC)';
  $$refSTR{'pattern21'}       = '%z - Time zone offset (Ex.: -0500)';
  $$refSTR{'pattern22'}       = '%P - am or pm';
  $$refSTR{'matchPattern'}    = 'Match Pattern';
  $$refSTR{'Both'}            = 'Both';
  $$refSTR{'None'}            = 'None';
  $$refSTR{'Add'}             = 'Add';
  $$refSTR{'Edit'}            = 'Edit';
  $$refSTR{'Parsed'}          = 'Parsed';
  $$refSTR{'otherOffset'}     = 'Other, offset';
  $$refSTR{'otherName'}       = 'Other, name';
  $$refSTR{'provideSample'}   = 'You must provide a sample';
  $$refSTR{'providePattern'}  = 'You must provide a pattern';
  # Config Window
  $$refSTR{'Settings'}        = 'Settings';
  $$refSTR{'General'}         = 'General';
  $$refSTR{'Databases'}       = 'Databases';
  $$refSTR{'AutoUpdateTip'}   = 'Check for update at startup';
  $$refSTR{'selectDBFile'}    = 'Select the database file';
  $$refSTR{'downloadDB'}      = 'Download or update the database';
  $$refSTR{'firstStart'}      = 'This is your first use of XL-Tools. Do you want to set default configuration?';
  $$refSTR{'defaultDir'}      = 'Do you want to use default dir';
  $$refSTR{'selectFolder'}    = 'Select a folder';
  $$refSTR{'SetGenOpt'}       = 'Set General Options';
  $$refSTR{'winPb'}           = 'Progress';
  $$refSTR{'winCW'}           = 'Configuration Wizard';
  $$refSTR{'XLWhoisExists'}   = 'Is XL-Whois installed on this system';
  $$refSTR{'configSet'}       = 'XL-Tool has been configured!';
  $$refSTR{'configSetPart'}   = 'Aborted! XL-Tool has been partially configured.';
  # General tab
  $$refSTR{'Tool'}            = 'Tool';
  $$refSTR{'Export'}          = 'Export';
  $$refSTR{'OpenUserDir'}     = 'Open user dir';
  $$refSTR{'checkUpdate'}     = 'Check Update';
  $$refSTR{'OptFunctions'}    = 'Functions';
  $$refSTR{'chFullScreen'}    = 'Start Full Screen';
  $$refSTR{'chRememberPos'}   = 'Remember position';
  $$refSTR{'MaxSize'}         = 'Max size (List)';
  $$refSTR{'chars'}           = 'chars';
  $$refSTR{'chooseFont'}      = 'Choose font';
  $$refSTR{'localTimezone'}   = 'Local timezone';
  $$refSTR{'defaultLang'}     = 'Default language';
  $$refSTR{'outputCharset'}   = 'Output charset';
  $$refSTR{'NsLookupTO1'}     = 'Nslookup timeout';
  $$refSTR{'UserAgent'}       = 'User-Agent';
  $$refSTR{'NoResultOpt'}     = 'When no result';
  $$refSTR{'NoResultOpt1'}    = 'Leave a blank';
  $$refSTR{'NoResultOpt1Tip'} = 'When a function gives no result, leave a blank.';
  $$refSTR{'NoResultOpt2'}    = 'Show status';
  $$refSTR{'NoResultOpt2Tip'} = 'Write the reason why there is no result (error, no match, etc.).';
  # Database tab
  $$refSTR{'noDB'}            = 'No database';
  $$refSTR{'OUIDB'}           = 'OUI (MAC Addresses)';
  $$refSTR{'GeoIP'}           = 'GeoIP';
  $$refSTR{'GeoIPDB'}         = 'GeoIP database';
  $$refSTR{'GeoIPNotice'}     = 'This product includes GeoLite2 data created by MaxMind, available from https://www.maxmind.com.';
  $$refSTR{'XLWhois'}         = 'XL-Whois (ISP)';
  $$refSTR{'XLWhoisDB'}       = 'XL-Whois database';
  $$refSTR{'IINLocalDB'}      = 'IIN (Credit cards)';
  $$refSTR{'selPathDB'}       = 'Select the path for the database';
  $$refSTR{'createdDB'}       = 'The database has been created';
  $$refSTR{'currDBDate'}      = 'Current DB date';
  $$refSTR{'remoteDBDate'}    = 'DB date on';
  $$refSTR{'updateAvailable'} = 'An update of the database is available, download';
  $$refSTR{'DBUpToDate'}      = 'Your database is up to date';
  $$refSTR{'createDBTable'}   = 'Create database and table';
  $$refSTR{'MACOUIDB'}        = 'MAC OUI Database';
  $$refSTR{'Locate'}          = 'Locate';
  $$refSTR{'Convert'}         = 'Convert';
  $$refSTR{'IINDB'}           = 'IIN database';
  $$refSTR{'NotExistDownload'} = 'does not exist, download';
  $$refSTR{'HasBeenUpdated'}  = 'has been updated';
  $$refSTR{'OSMDB'}           = 'OpenStreetMap database';
  $$refSTR{'Email'}           = 'Email';
  $$refSTR{'OSMNotice'}       = 'Data © OpenStreetMap contributors, ODbL 1.0. https://osm.org/copyright';
  # Update Window
  $$refSTR{'Update'}          = 'Update';
  $$refSTR{'update1'}         = 'You have the latest version installed.';
  $$refSTR{'update2'}         = 'Check for update';
  $$refSTR{'update5'}         = 'is available. Download it';
  $$refSTR{'update6'}         = 'is available. Update';
  $$refSTR{'update7'}         = 'Note: Program must be restarted.';
  $$refSTR{'NotNow'}          = 'Not now';
  # About Window
  $$refSTR{'Version'}         = 'Version';
  $$refSTR{'Author'}          = 'Author';
  $$refSTR{'TranslatedBy'}    = 'Translated by';
  $$refSTR{'Website'}         = 'Website';
  $$refSTR{'translatorName'}  = '-';

}  #--- End loadDefaultStr

#------------------------------------------------------------------------------#
1;