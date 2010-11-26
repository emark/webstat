#Модуль статистики голосований постов
package PostStat;
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
    &QueryTopList();
}

sub QueryTopList()
{
    $SQL="SELECT URL,SUM(ANSWER) AS SUM,COUNT(ANSWER) AS COUNT FROM POSTSTAT GROUP BY URL ORDER BY SUM DESC";
    #print $SQL;
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    while ($ref=$sth->fetchrow_hashref)
    {
        $ref->{'URL'}=~/(\/\d+\/\d+\/.*\/)/;
        print "$1\t$ref->{'SUM'}\t$ref->{'COUNT'}\n";
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