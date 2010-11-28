#Модуль статистики кликабельности постов
package UrlStat;
use strict;
#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='UrlStat';

BEGIN;

sub Init()
{
    #Connection with database
    my @pages=('URL','REFERER');
    $dbh=DBI->connect("DBI:mysql:database=COMMON;host=localhost","root","admin");
    $dbh->trace();
    foreach my $key(@pages)
    {
        #print "<a href=\"\">$key</a>&nbsp";
    }
    &QueryClickability($pages[$_[0]]);
    &Disconnect;
}
#Процедура подсчета кликабельности
#EXP: URL, REFERER
sub QueryClickability()
{
    my $name='';
    my $n=0;
    my %domain=('URL'=>'http://',
                'REFERER'=>'http://www.web2buy.ru'
               );
    $SQL="SELECT $_[0],COUNT(URL) AS CLICKABILITY FROM URLSTAT GROUP BY $_[0] ORDER BY CLICKABILITY DESC LIMIT 20";
    $sth=$dbh->prepare($SQL);#print $SQL;
    $sth->execute();
    print '<table border=1 width=100%>';
    while ($ref=$sth->fetchrow_hashref)
    {
        $n++;
        $name=substr($ref->{$_[0]},0,250);
        print "<tr><td>$n</td><td><a href=\"$domain{$_[0]}$ref->{$_[0]}\" target=_blank>$name</a></td><td>$ref->{'CLICKABILITY'}</td></tr>\n";
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