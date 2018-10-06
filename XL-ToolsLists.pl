#!/usr/bin/perl
# Perl - v: 5.16.3
#------------------------------------------------------------------------------#
# XL-ToolsUtils.pl  : List functions for XL-Tools
# WebSite           : http://le-tools.com/XL-Tools.html
# SourceForge       : https://sourceforge.net/p/xl-tools
# GitHub            : https://github.com/arioux/XL-Tools
# Documentation     : http://le-tools.com/XL-ToolsDoc.html
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

#--------------------------#
sub enumItems
#--------------------------#
{
  # Local variables
  my ($refList, $refWin, $refSTR) = @_;
  my @items;
  # Enumerate items
  my $first = $$refList->GetLine(0);
  my $file;
  if ($first =~ /^$$refSTR{'useFile'}: \"([^\"]+)\"$/) { $file = $1; }
  if ($file and -T $file) {
    # Items are in a file
    if (open my $fh, '<', $file) {
      while (<$fh>) { chomp($_); push(@items, $_); }
      close($fh);
    } else { Win32::GUI::MessageBox($$refWin, "$$refSTR{'errorReading'}: ".$!, $$refSTR{'error'}, 0x40010); }
  } else {
    # Items are in the textfield
    for (my $i = 0; $i < $$refList->GetLineCount(); $i++) {
      my $item = $$refList->GetLine($i);
      chomp($item);
      push(@items, $item);
    }
  }
  pop(@items) if !$items[-1];
  return(\@items);
  
}  #--- End enumItems

#--------------------------#
sub writeResults
#--------------------------#
{
  # Local variables
  my ($refItems, $refConfig, $refWin, $refSTR) = @_;
  my $nbrItems = 0;
  if ($$refItems) {
    my $nbrChars = length($$refItems);
    # Max of chars reached or exceeded
    if ($nbrChars >= $$refWin->tfList3->MaxLength() or $$refWin->chList3InFile->Checked()) {
      my $answer;
      if (!$$refWin->chList3InFile->Checked()) {
        # Ask to write results in a file
        $answer = Win32::GUI::MessageBox($$refWin, $$refSTR{'saveToFileMsg'}, $$refSTR{'saveToFile'}, 0x40023);
        if    ($answer == 2) { return; }                              # Cancel (2)
        elsif ($answer == 7) { $$refWin->tfList3->Text($$refItems); } # No (7), write truncated text
      }
      # Yes
      if (($answer and $answer == 6) or $$refWin->chList3InFile->Checked()) {
        # Extract directory of the input file
        my $first  = $$refWin->tfList1->GetLine(0);
        my $resDir = '';
        if ($first =~ /^$$refSTR{'useFile'}: \"([^\"]+)\"$/) { $resDir = $1; }
        if ($resDir) {
          my @dir = split(/\\/, $resDir);
          pop(@dir);
          $resDir = join("\\", @dir);
        }
        # Show OpenFile dialog window
        my $file = Win32::GUI::GetSaveFileName( -title              => $$refSTR{'saveToFile'}.'. '.$$refSTR{'selectFile'},
                                                -directory          => $resDir                                           ,
                                                -file               => 'temp.txt'                                        ,
                                                -defaultextension   => 'txt'                                             ,
                                                -filter             => ["$$refSTR{'text'} (*.txt)", "*.txt"]             ,
                                                -defaultfilter      => 0                                                 ,
                                                -createprompt       => 1                                                 , );
        if ($file) {
          # Copy results in the file
          if (open my $fh, '>', $file) {
            my @tab = split(/\r\n/, $$refItems);
            foreach (@tab) { print $fh "$_\n"; $nbrItems++; }
            close($fh);
            $$refWin->tfList3->Text("\"$file\"");
            &tfList3_Change();
          } else { Win32::GUI::MessageBox($$refWin, "$$refSTR{'errorWriting'}: ".$!, $$refSTR{'error'}, 0x40010); }
        }
      }
    } else {
      $$refItems = encode($$refConfig{'OUTPUT_CHARSET'}, $$refItems);
      $$refWin->tfList3->Text($$refItems);
      &tfList3_Change();
      $nbrItems = $$refWin->tfList3->GetLineCount() - 1;
    }
  }
  $$refWin->lblList3Count->Text($nbrItems);
  
}  #--- End writeResults

#--------------------------#
sub showReplaceREStatus
#--------------------------#
{
  # Local variables
  my $refWin = shift;
  my $regex  = $$refWin->tfReplace->Text();
  if ($regex) {
    my ($statusRegex, $msg) = &validRegex($regex);
    # Warning
    if      ($statusRegex == 2) {
      $$refWin->lblReplaceREWarn->Show();
      $$refWin->lblReplaceREOk->Hide();
      $$refWin->lblReplaceREErr->Hide();
    # Error
    } elsif ($statusRegex == 1) {
      $$refWin->lblReplaceREErr->Show();
      $$refWin->lblReplaceREOk->Hide();
      $$refWin->lblReplaceREWarn->Hide();
    # Ok
    } else {
      $$refWin->lblReplaceREOk->Show();
      $$refWin->lblReplaceREErr->Hide();
      $$refWin->lblReplaceREWarn->Hide();
    }
  } else {
    $$refWin->lblReplaceREOk->Hide();
    $$refWin->lblReplaceREErr->Hide();
    $$refWin->lblReplaceREWarn->Hide();
  }

}  #--- End showReplaceREStatus

#--------------------------#
sub validRegex
#--------------------------#
{
  # Local variables
  my $regex = shift;
  if ($regex) {
    eval { if ('test' =~ /$regex/) { } };
    if ($@) {
      my $errRegex = (split(/ at /,$@))[0];
      return(1, $errRegex);
    } else {
      # Valid but senseless regex
      if ($regex =~ /^\||\|\||(?:[^\\]\|$)/ or $regex =~ /^\(\.\*\)$/) { return(2, undef); }
      else { return(0, undef); }
    }
  }
  
}  #--- End validRegex

#--------------------------#
sub showReplaceByREStatus
#--------------------------#
{
  # Local variables
  my $refWin = shift;
  my $expr   = $$refWin->tfReplBy->Text();
  if ($$refWin->chRegex->Checked() and $expr) {
    my ($status, $msg) = &validReplacement($refWin);
    # Warning
    if      ($status and $status == 2) {
      $$refWin->lblReplaceByREWarn->Show();
      $$refWin->lblReplaceByREOk->Hide();
      $$refWin->lblReplaceByREErr->Hide();
    # Error
    } elsif ($status) {
      $$refWin->lblReplaceByREErr->Show();
      $$refWin->lblReplaceByREOk->Hide();
      $$refWin->lblReplaceByREWarn->Hide();
    # Ok
    } else {
      $$refWin->lblReplaceByREOk->Show();
      $$refWin->lblReplaceByREErr->Hide();
      $$refWin->lblReplaceByREWarn->Hide();
    }
  } else {
    $$refWin->lblReplaceByREOk->Hide();
    $$refWin->lblReplaceByREErr->Hide();
    $$refWin->lblReplaceByREWarn->Hide();
  }

}  #--- End showReplaceByREStatus

#--------------------------#
sub validReplacement
#--------------------------#
{
  # Local variables
  my $refWin = shift;
  my $expr = $$refWin->tfReplBy->Text();
  my $test = 'test';
  $expr = '"' . $expr . '"' if $expr =~ /\$1/ and !$$refWin->chEval->Checked(); # Capture with Eval not checked
  if ($$refWin->chEval->Checked() or $expr =~ /\$1/) { $test =~ s/(.+)/$expr/eegi; } # Regex
  else                                               { $test =~ s/(.+)/$expr/gi;   } # Keyword
  if ($@) { # Error
    my $err = (split(/ at /,$@))[0];
    return(1, $err);
  } else {
    return(2, undef) if $expr =~ /[\<\>\:\"\/\\\|\?\*]/; # Warning for illegal characters
    return(0, undef); # Replacement ok
  }  
  
}  #--- End validReplacement

#--------------------------#
sub noDuplicates
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my %items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    if ($item) {
      my $newItem = $item; # Copy of the item
      # Match case
      $newItem = lc($newItem) if !$$refWin->chMatchCase->Checked();
      # Keep item if doesn't exist already
      $items{$newItem} = $item if length($newItem) != 0 and !exists($items{$newItem});
    }
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (sort values %items) { $itemsRes .= "$_\r\n" if $_; }
  return(\$itemsRes);  
  
}  #--- End noDuplicates

#--------------------------#
sub onlyDuplicates
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my %items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    if ($item) {
      my $newItem = $item; # Copy of the item
      # Match case
      $newItem = lc($newItem) if !$$refWin->chMatchCase->Checked();
      # Keep item
      if (length($newItem) != 0) {
        if    (!exists($items{$newItem})) { $items{$newItem} = '&1&'; }
        elsif ($items{$newItem} eq '&1&') { $items{$newItem} = $item; }
      }
    }
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (keys %items) { $itemsRes .= "$_\r\n" if $_ and $items{$_} ne '&1&'; }
  return(\$itemsRes);  
  
}  #--- End noDuplicates

#--------------------------#
sub countDuplicates
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my %items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    if ($item) {
      my $newItem = $item; # Copy of the item
      # Match case
      $newItem = lc($newItem) if !$$refWin->chMatchCase->Checked();
      # Keep item if doesn't exist already
      if (length($newItem) != 0) {
        if (exists($items{$newItem})) {
          my ($item, $nbr) = split(/\|\|\|/, $items{$newItem});
          $nbr++;
          $items{$newItem} = "$item\|\|\|$nbr";
        } else { $items{$newItem} = "$item\|\|\|1"; }
      }
    }
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (sort values %items) {
    if ($_) {
      $itemsRes .= $_;
      $itemsRes =~ s/\|\|\|/\t/;
    }
    $itemsRes .= "\r\n";
  }
  return(\$itemsRes);  
  
}  #--- End countDuplicates

#--------------------------#
sub countChars
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("$curr / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item      =~ s/[\r\n]//g;  # Remove any line break
    my $length = length($item);
    push(@items, $length);
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);  
  
}  #--- End countChars

#--------------------------#
sub L1_less_L2
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  my $nbrItems = scalar(@{$refList1}) + scalar(@{$refList2});
  my $curr     = 0;
  my %items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of List 1
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    if ($item) {
      my $newItem = $item; # Copy of the item
      $newItem = lc($newItem) if !$$refWin->chMatchCase->Checked(); # Match case
      $items{$newItem} = $item if length($newItem) != 0 and !exists($items{$newItem}); # Keep item if doesn't exist already
    }
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Loop on each item of List 2
  foreach my $item (@{$refList2}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    if ($item) {
      my $newItem = $item; # Copy of the item
      $newItem = lc($newItem) if !$$refWin->chMatchCase->Checked(); # Match case
      delete($items{$newItem}) if exists($items{$newItem}) and (length($newItem) != 0); # If item exists already, delete it
    }
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (sort values %items) { $itemsRes .= "$_\r\n" if $_; }
  return(\$itemsRes);  
  
}  #--- End L1_less_L2

#--------------------------#
sub col2row
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $separator = $$refWin->tfWith->Text();
  my $nbrItems  = scalar(@{$refList1});
  my $curr      = 0;
  my $itemsRes;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    $itemsRes .= $item;
    $itemsRes .= $separator if $separator;
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  $itemsRes =~ s/$separator$// if $separator;
  $itemsRes .= "\r\n";
  return(\$itemsRes);  
  
}  #--- End col2row

#--------------------------#
sub row2col
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $separator = quotemeta($$refWin->tfWith->Text());
  my $nbrItems  = scalar(@{$refList1});
  my $curr      = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    my @temp;
    $item =~ s/[\r\n]//g;  # Remove any line break
    if ($item =~ /$separator/) { @temp = split(/$separator/, $item); }
    else                       { push(@temp, $item);                 }
    push(@items, @temp);
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);  
  
}  #--- End row2col

#--------------------------#
sub list2regex
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrItems  = scalar(@{$refList1});
  my $curr      = 0;
  my $itemsRes;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item     =~ s/[\r\n]//g;  # Remove any line break
    $itemsRes .= quotemeta($item)."\|" if $item;
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  while ($itemsRes =~ /(?:[^\\]\|$)/) { chop($itemsRes); }
  $itemsRes .= "\r\n";
  return(\$itemsRes);  
  
}  #--- End list2regex

#--------------------------#
sub concatStr
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  my $nbrItems = scalar(@{$refList1}) >= scalar(@{$refList2}) ? scalar(@{$refList1}) : scalar(@{$refList2});
  my $expr     = $$refWin->tfWith->Text();
  my $curr     = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of two lists at the same time
  for (my $i = 0; $i < $nbrItems; $i++) {
    my $resItem = '';
    if (defined($$refList1[$i])) {
      $$refList1[$i] =~ s/[\r\n]//g;
      $resItem .= $$refList1[$i];
    }
    $resItem .= $expr if $expr;
    if (defined($$refList2[$i])) {
      $$refList2[$i] =~ s/[\r\n]//g;
      $resItem .= $$refList2[$i];
    }
    push(@items, $resItem) if $resItem ne $expr;
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);  
  
}  #--- End concatStr

#--------------------------#
sub splitStr
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $expr     = $$refWin->tfWith->Text();
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  $expr = quotemeta($expr) if !$$refWin->chRegex->Checked();
  foreach my $item (@{$refList1}) {
    $item       =~ s/[\r\n]//g;  # Remove any line break
    my $resItem = '';
    my @fields  = split(/$expr/, $item);
    foreach (@fields) { $resItem .= "$_\t"; }
    chop($resItem);
    push(@items, $resItem);
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);
  
}  #--- End splitStr

#--------------------------#
sub splitExtract
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $expr     = $$refWin->tfWith->Text();
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my %cols;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach (split(/,[ ]?/, $$refWin->tfColumnsNo->Text())) { $cols{$_} = 1; }
  $expr = quotemeta($expr) if !$$refWin->chRegex->Checked();
  foreach my $item (@{$refList1}) {
    $item       =~ s/[\r\n]//g;  # Remove any line break
    my $resItem = '';
    my @fields  = split(/$expr/, $item, -1);
    my $currCol = 0;
    foreach (@fields) {
      $currCol++;
      $resItem .= "$_\t" if exists($cols{$currCol});
    }
    $resItem .= pop(@fields)."\t" if exists($cols{'-1'}); # Last column no matter how many columns there are
    chop($resItem);
    push(@items, $resItem);
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);
  
}  #--- End splitExtract

#--------------------------#
sub mergeLines
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrColumns = $$refWin->tfColumnsNo->Text();
  my $nbrItems   = scalar(@{$refList1});
  my $curr       = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  my $count   = 0;
  my $resItem = '';
  foreach my $item (@{$refList1}) {
    $item    =~ s/[\r\n]//g;  # Remove any line break
    $resItem .= $item . "\t";
    $count++;
    if ($count == $nbrColumns) {
      chop($resItem);
      push(@items, $resItem);
      $count   = 0;
      $resItem = '';
    }
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);  
  
}  #--- End mergeLines

#--------------------------#
sub splitMerge
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $expr       = $$refWin->tfWith->Text();
  my $nbrItems   = scalar(@{$refList1});
  my $nbrColumns = $$refWin->tfColumnsNo->Text();
  my $curr       = 0;
  my $headers;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  $expr = quotemeta($expr) if !$$refWin->chRegex->Checked();
  my $header  = 0;
  my $count   = 0;
  my $resItem = '';
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    my ($field, $value) = split(/$expr/, $item);
    $headers .= $field . "\t" if !$header; # Gather header strings
    $resItem .= $value . "\t";
    $count++;
    if ($count == $nbrColumns) {
      $header++;
      if ($header == 1) { chop($headers); push(@items, $headers); }
      chop($resItem);
      push(@items, $resItem);
      $count = 0;
      $resItem = '';
    }
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);
  
}  #--- End splitMerge

#--------------------------#
sub replace
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $srcExpr      = $$refWin->tfReplace->Text();
  my $srcExprCase  = $$refWin->chMatchCase->Checked();
  my $srcExprRegex = $$refWin->chRegex->Checked();
  my $dstExpr      = $$refWin->tfReplBy->Text();
  my $dstExprEval  = $$refWin->chEval->Checked();
  my $nbrItems     = scalar(@{$refList1});
  my $curr         = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Escape replace expresion if not regex
  if    (!$srcExprRegex)                      { $srcExpr = quotemeta($srcExpr);  }
  elsif ($dstExpr =~ /\$1/ and !$dstExprEval) { $dstExpr = '"' . $dstExpr . '"'; }
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    if (($srcExprCase and $item =~ /$srcExpr/) or (!$srcExprCase and $item =~ /$srcExpr/i)) {
      if ($srcExprCase) {
        if ($srcExprRegex and ($dstExprEval or $dstExpr =~ /\$1/)) { # Expression must be evaluated
          $item =~ s/$srcExpr/$dstExpr/eeg;
        } else { $item =~ s/$srcExpr/$dstExpr/g; } # Keyword
      } else {
        if ($srcExprRegex and ($dstExprEval or $dstExpr =~ /\$1/)) { # Expression must be evaluated
          $item =~ s/$srcExpr/$dstExpr/eegi;
        } else { $item =~ s/$srcExpr/$dstExpr/gi; } # Keyword
      }
    }
    push(@items, $item);
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);
  
}  #--- End replace

#--------------------------#
sub reverseStr
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    push(@items, scalar reverse($item));
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);  
  
}  #--- End reverseStr

#--------------------------#
sub transliterate
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $srcExpr  = $$refWin->tfReplace->Text();
  my $dstExpr  = $$refWin->tfReplBy->Text();
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    $_    = $item;
    eval "tr/\Q$srcExpr\E/\Q$dstExpr\E/";
    $item = $_;
    push(@items, $item);
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);
  
}  #--- End transliterate

#--------------------------#
sub lowercase
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g; # Remove any line break
    if    ($$refWin->rbAll->Checked())       { push(@items, lc($item));      } # Lowercase all characters
    elsif ($$refWin->rbFirstOnly->Checked()) { push(@items, lcfirst($item)); } # Lowercase first character only
    else { # Lowercase first letter of each word
      my $newItem;
      my @words = split(/ /, $item);
      foreach (@words) { $newItem .= lcfirst($_).' '; }
      chop($newItem);
      push(@items, $newItem);
    }
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);  
  
}  #--- End lowercase

#--------------------------#
sub uppercase
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g; # Remove any line break
    if    ($$refWin->rbAll->Checked())       { push(@items, uc($item));      } # Uppercase all characters
    elsif ($$refWin->rbFirstOnly->Checked()) { push(@items, ucfirst($item)); } # Uppercase first character only
    else { # Uppercase first letter of each word
      my $newItem;
      my @words = split(/ /, $item);
      foreach (@words) { $newItem .= ucfirst($_).' '; }
      chop($newItem);
      push(@items, $newItem);
    }
    # Progress
    $curr++;
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);  
  
}  #--- End uppercase

#--------------------------#
sub addLineNumber
#--------------------------#
{
  # Local variables
  my ($refList1, $refList2, $refWin, $refSTR) = @_;
  push(@{$refList1}, @{$refList2}); # Merge lists
  my $nbrItems = scalar(@{$refList1});
  my $curr     = 0;
  my @items;
  # Progress
  $$refWin->pb->SetRange(0, $nbrItems);
  $$refWin->pb->SetPos(0);
  $$refWin->pb->SetStep(1);
  $$refWin->lblPbCurr->Text($$refSTR{'runningProcess'}.'...');
  $$refWin->lblPbCount->Text("0 / $nbrItems");
  # Loop on each item of merged list
  foreach my $item (@{$refList1}) {
    $item =~ s/[\r\n]//g;  # Remove any line break
    $curr++;
    push(@items, $curr."\t".$item);
    # Progress
    $$refWin->lblPbCount->Text("$curr / $nbrItems");
    $$refWin->pb->StepIt();
  }
  # Format results
  my $itemsRes;
  foreach (@items) { $itemsRes .= "$_\r\n"; }
  return(\$itemsRes);  
  
}  #--- End addLineNumber

#------------------------------------------------------------------------------#
1;