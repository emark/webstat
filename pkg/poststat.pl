#Модуль статистики голосований постов
package PostStat;
use strict;
#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='PostStat';

BEGIN;

sub Init()
{
    #Connection with database
    $dbh=DBI->connect("DBI:mysql:database=COMMON;host=localhost","root","admin");
    $dbh->trace();
    &QueryTopList();
    &Disconnect;
}

sub QueryTopList()
{
    my $n=0;
    $SQL="SELECT URL,SUM(ANSWER) AS SUM,COUNT(ANSWER) AS COUNT FROM POSTSTAT GROUP BY URL ORDER BY SUM DESC LIMIT 10";
    #print $SQL;
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    print '<table border=1 width=100%>';
    while ($ref=$sth->fetchrow_hashref)
    {
        $n++;
        $ref->{'URL'}=~/(\/\d+\/\d+\/.*\/)/;
        print "<tr><td>$n</td><td>$1</td><td>$ref->{'SUM'}</td><td>$ref->{'COUNT'}</td></tr>\n";
    }
    print '</table>';
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

return $module;
END;