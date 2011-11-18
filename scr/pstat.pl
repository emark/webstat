#!/usr/bin/perl -w
use strict;
use CGI;
use DBI;
require '../sys/syspkg.pl';

my $dbconf='../db.conf';
my $dbh=DBI->connect(&Syspkg::DBconf($dbconf));
my $sth=undef;
my $SQL='';
#Variables init
my $query=new CGI;
my $variant=$query->param('variant');
my $host=$ENV{'HTTP_HOST'};
my $url=$ENV{'HTTP_REFERER'};
my $ip=$ENV{'REMOTE_ADDR'};

if($url)
{
    #Удаление http://имя_хоста из URL
    $url=~s/http:\/\/$host//;

    $SQL="INSERT INTO POSTSTAT(URL,DATE,IP,ANSWER) VALUES('$url',NOW(),'$ip',$variant)";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    print $query->header();
}
else
{
    print $query->redirect('http://'.$ENV{'HTTP_HOST'});
}