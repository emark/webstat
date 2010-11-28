#!/usr/bin/perl -w
use strict;
use DBI;
use CGI;

my @modules=(require 'pkg/poststat.pl',
             require 'pkg/urlstat.pl'
             );
my $query=new CGI;
my $page=$query->param('page');
my $module=$query->param('module');
&HTMLDisplay;

sub HTMLDisplay()#Generate HTML headers & content
{
    print $query->header();
    print $query->start_form;
    print '<SELECT ID=module NAME=module>';
    foreach my $key(@modules)
    {
        print "<OPTION VALUE='$key'";
        if($module eq $key)
        {
            print ' selected ';
        }
        print ">$key</OPTION>";
    }
    print '</SELECT>';
    print $query->submit();
    print $query->end_form;
    &StartModule;
}

sub StartModule()#Starting selected module
{
    if($module eq $modules[0])
    {
        &PostStat::Init($page);    
    }
    elsif($module eq $modules[1])
    {
        &UrlStat::Init($page);    
    }
    else#Default module
    {
        &PostStat::Init;
    }
}
