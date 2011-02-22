#!/usr/bin/perl -w
use strict;
use DBI;
use CGI qw/:standard -debug/;
use CGI::Carp 'fatalsToBrowser';
use constant VERSION=>1.2;
require 'pkg/datecal.pl';
require 'pkg/syspkg.pl';

my @modules=(require 'pkg/loyalty.pl',
             require 'pkg/clickability.pl',
             require 'pkg/chart.pl',
             require 'pkg/registry.pl',
             );

my $query=new CGI;
my $module=param('module') || '';
my @modoption=param('modoption');#Module option parameters
&Datecal::GetDates(param('date_in'),
                    param('date_out')
                    );
&StartModule;

sub HTMLDisplay()#Generate HTML headers & content
{
    print header(-charset=>'UTF-8');
    print start_html(-title=>'Webstat '.VERSION,
                             -style=>'/stat/style.css'
                             );
    print start_form(-name=>'DatePeriod',
                     -method=>'post',
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
    print submit();
    print '</P><P align=center>';
    &Datecal::Rewind($module);
    print textfield(-name=>'date_in',
                          -size=>12,
                          -value=>&Datecal::DateIn,
                          -override=>1,
                          -maxlength=>10);
    print '&nbsp;-&nbsp;';
    print textfield(-name=>'date_out',
                          -size=>12,
                          -value=>&Datecal::DateOut,
                          -override=>1,
                          -maxlength=>10);
    &Datecal::Forward($module);
    print end_form;
    print '</P>';
}

sub HTMLfinish()
{
    print end_html;
}

sub StartModule()#Starting selected module
{
    if($module eq $modules[0])
    {
        &Loyalty::Init(Datecal::Period(),@modoption);    
    }
    elsif($module eq $modules[1])
    {
        &Clickability::Init(Datecal::Period(),@modoption);    
    }
    elsif($module eq $modules[2])
    {
        &Chart::Init(Datecal::Period(),@modoption);    
    }
    elsif($module eq $modules[3])
    {
        &Registry::Init(@modoption);
    }
    else#Default module
    {
        &Loyalty::Init(Datecal::Period(),@modoption);
    }
}
