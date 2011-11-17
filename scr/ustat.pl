#!/usr/bin/perl -w
#1.07
use strict;
use CGI;
use DBI;

#Определение параметров БД
my $dbhost='mysql0.locum.ru';
my $dbase='locumtes_web2b58';
my $user='locumtes_web2b58';
my $pass='qJ8O1JSg';
my $SQL='';
my $dbh=DBI->connect("DBI:mysql:database=$dbase;host=$dbhost",$user,$pass) || die "Can't connect to database: $dbase at $dbhost";
my $sth=undef;
#Инициализация переменных
my $query=new CGI;
my $url=$ENV{'QUERY_STRING'};
my $host=$ENV{'HTTP_HOST'};
my $ip=$ENV{'REMOTE_ADDR'};
my $referer=$ENV{'HTTP_REFERER'} || '';
my $user_agent='';
my $track='';

#if($url && $referer ne '')
if($url)
{
    $referer=~s/http:\/\/$host//;#Удаляем из Referer имя хоста
    $url=~s/^url=//;#Удаляем префикс url= из строки запроса
    $url=~s/\@.*//;#Удаляем tracking код из запроса
    $user_agent=substr ($ENV{'HTTP_USER_AGENT'},0,80);#Сокращаем до 80 символов USER_AGENT
    $SQL="INSERT INTO $dbase.URLSTAT(URL,DATE,IP,REFERER,USER_AGENT) VALUES('$url',NOW(),'$ip','$referer','$user_agent')";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    print $query->redirect('http://'.$url);        
}
else
{
    print $query->redirect('http://'.$ENV{'HTTP_HOST'});
}
