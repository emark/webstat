#Модуль статистики кликабельности постов
package UrlStat;
use strict;
#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';

BEGIN;

sub Init()
{
    #Connection with database
    $dbh=DBI->connect("DBI:mysql:database=COMMON;host=localhost","root","admin");
    $dbh->trace();
    &QueryClickability('URL');
}

sub QueryClickability()
{
    $SQL="SELECT $_[0],COUNT(URL) AS CLICKABILITY FROM URLSTAT GROUP BY $_[0] ORDER BY CLICKABILITY DESC";
    $sth=$dbh->prepare($SQL);#print $SQL;
    $sth->execute();
    while ($ref=$sth->fetchrow_hashref)
    {
        print "$ref->{$_[0]}\t$ref->{'CLICKABILITY'}\n";
    }
    return 1;
}
    
sub Disconnect()
{
    $ref=undef;
    $sth=undef;
    $dbh->disconnect;
    $dbh=undef;
    print 'Connection close';
}

return 1;
END;