#!/usr/bin/perl -w
use strict;
use DBI;
use CGI;
require 'pkg/poststat.pl';
require 'pkg/urlstat.pl';

my $query=new CGI;
print $query->header();
print $query->pre;
my $page=$query->param('page');
my $module=$query->param('module');

if($module eq 'poststat')
{
    &PostStat::Init;
}
elsif($module eq 'urlstat')
{
    &UrlStat::Init($page);    
}
