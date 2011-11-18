#!/usr/bin/perl -w
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
my $variant=$query->param('variant');
my $host=$ENV{'HTTP_HOST'};
my $url=$ENV{'HTTP_REFERER'};
my $ip=$ENV{'REMOTE_ADDR'};

if($url)
{
    #Удаление http://имя_хоста из URL
    $url=~s/http:\/\/$host//;

    $SQL="INSERT INTO $dbase.POSTSTAT(URL,DATE,IP,ANSWER) VALUES('$url',NOW(),'$ip',$variant)";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    print $query->header();
}
else
{
    print $query->redirect('http://'.$ENV{'HTTP_HOST'});
}
#print '<PRE>';foreach my $key(keys %ENV){print $key."\t$ENV{$key}\n";};#print $SQL;
