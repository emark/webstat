#!/usr/bin/perl -w
use strict;
use DBI;
use CGI;
use constant VERSION=>1.1;
require 'pkg/datecal.pl';
require 'pkg/syspkg.pl';

my @modules=(require 'pkg/loyalty.pl',
             require 'pkg/clickability.pl',
             require 'pkg/chart.pl'
             );

my $query=new CGI;
my $module=$query->param('module');
my $modoption=$query->param('modoption');#Module option parameters
&Datecal::GetDates($query->param('date_in'),
                    $query->param('date_out')
                    );

&HTMLDisplay;

sub HTMLDisplay()#Generate HTML headers & content
{
    print $query->header(-charset=>'UTF-8');
    print $query->start_html(-title=>'Webstat',
                             -style=>'/stat/style.css'
                             );
    print $query->start_form(-method=>'post',
                             -action=>'?'
                             );
    print '<P class=presetdates>';
    &Datecal::PresetDates($module);
    print '</P><P><SELECT ID=module NAME=module>';
    foreach my $key(@modules)
    {
        print "<OPTION VALUE='$key'";
        if($module eq $key)
        {
            print ' selected ';
        }
        print ">$key</OPTION>";
    }
    print '</SELECT>&nbsp;';
    print $query->submit();
    print '</P><P align=center>';
    &Datecal::Rewind($module);
    print $query->textfield(-name=>'date_in',
                          -size=>12,
                          -value=>&Datecal::DateIn,
                          -maxlength=>10);
    print '&nbsp;-&nbsp;';
    print $query->textfield(-name=>'date_out',
                          -size=>12,
                          -value=>&Datecal::DateOut,
                          -maxlength=>10);
    &Datecal::Forward($module);
    print $query->end_form;
    print '</P>';
    &StartModule;
}

sub StartModule()#Starting selected module
{
    print "<P align=center class=caption>Report for $module</P>";
    if($module eq $modules[0])
    {
        &Loyalty::Init(Datecal::Period(),$modoption);    
    }
    elsif($module eq $modules[1])
    {
        &Clickability::Init(Datecal::Period(),$modoption);    
    }
    elsif($module eq $modules[2])
    {
        &Chart::Init(Datecal::Period(),$modoption);    
    }
    else#Default module
    {
        &Loyalty::Init(Datecal::Period(),$modoption);
    }
}
