#!/usr/bin/perl -w
use strict;
use constant VERSION=>0.7;
use CGI;
use DBI;
require '../sys/syspkg.pl';

#Change current directory
chdir('../');
my $dbconf='db.conf';
my $dbh=DBI->connect(&Syspkg::Static($dbconf));
my $sth=undef;
my $SQL='';
#Define CGI variables
my $query=new CGI;
my $url=$ENV{'QUERY_STRING'};
my $host=$ENV{'HTTP_HOST'};
my $ip=$ENV{'REMOTE_ADDR'};
my $referer=$ENV{'HTTP_REFERER'} || '';
my $user_agent='';
my $track='';

if($url && $referer ne '')
{
    $referer=~s/http:\/\///;#Drop http:// from Referer
    $referer=~s/$host//;#Drop hostname from Referer
    $url=~s/^url=//;#remove url prefix
    $url=~s/\@.*//;#remove track variable
    $user_agent=substr ($ENV{'HTTP_USER_AGENT'},0,80);#cut length USER_AGENT to 80ch
    $SQL="INSERT INTO URLSTAT(URL,DATE,IP,REFERER,USER_AGENT) VALUES('$url',NOW(),'$ip','$referer','$user_agent')";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    print $query->redirect('http://'.$url);        
}
else
{
    print $query->redirect('http://'.$ENV{'HTTP_HOST'});
}

$sth=undef;
$dbh=undef;
