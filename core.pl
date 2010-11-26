#!/usr/bin/perl -w
use strict;
use DBI;
use CGI;
require 'pkg/poststat.pl';

my $query=new CGI;
#print $query->header();
#print $query->pre;

&PostStat::Init;