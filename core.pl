#!/usr/bin/perl -w
use strict;
use DBI;
use CGI qw/:standard/; #-debug
use CGI::Carp 'fatalsToBrowser';
use utf8;
use constant VERSION=>1.2;
require 'pkg/datecal.pl';
require 'sys/syspkg.pl';

my @modules=(require 'pkg/welcome.pl',
             require 'pkg/clickability.pl',
             require 'pkg/chart.pl',
             require 'pkg/registry.pl',
             require 'pkg/links.pl',
             );
our $dbconf='db.conf';#Database configfile
my $module=param('module') || '';
my @modoption=param('modoption');#Module option parameters
&Datecal::GetDates(param('date_in'),
                    param('date_out')
                    );
&StartModule;

sub HTMLDisplay()#Generate HTML headers & content
{
    print header(-charset=>'UTF-8');
    print start_html(-title=>'Webstat '.VERSION);
    print &Syspkg::Static('style.css');
    print "Root domain: <a href=\"http://$ENV{'HTTP_HOST'}\">$ENV{'HTTP_HOST'}</a>";
    print start_form(-name=>'DatePeriod',
                     -method=>'post',
                     -action=>'?'
                     );
    print '<P class=presetdates>';
    &Datecal::PresetDates($module);
    print '</P><P>Module: <SELECT ID=module NAME=module>';
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
    print submit(-value=>'Open module');
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
        &Welcome::Init(@modoption);    
    }elsif($module eq $modules[1])
    {
        &Clickability::Init(Datecal::Period(),@modoption);
    }elsif($module eq $modules[2])
    {
        &Chart::Init(Datecal::Period(),@modoption);    
    }elsif($module eq $modules[3])
    {
        &Registry::Init(@modoption);
    }elsif($module eq $modules[4])
    {
        &Links::Init(Datecal::Period(),@modoption);
    }else#Default module
    {
        &Welcome::Init(@modoption);
    }
}
