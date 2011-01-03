#Модуль статистики голосований постов *Лояльность*
package Loyalty;
use strict;
use constant VERSION=>1.06;

#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='Loyalty';

BEGIN;

sub Init()
{
    #Connection with database
    $dbh=DBI->connect(&Syspkg::DBconf);
    $dbh->trace();
    &QueryTopList($_[0],$_[1]);
    &Disconnect;
}

#Процедура подсчета рейтинга постов
#USAGE: $date_in,$date_out
sub QueryTopList()
{
    my $n=0;
    my $totalsum=0;
    my $totalcount=0;
    my $percent=0;
    my $bgcolor=0;
    my $rowlimit=20;#Ограничение на первичный вывод строк
    $SQL="SELECT URL,SUM(ANSWER) AS SUM,COUNT(ANSWER) AS COUNT FROM POSTSTAT WHERE DATE>='$_[0]' AND DATE<='$_[1]'
            GROUP BY URL ORDER BY SUM DESC";#print $SQL;
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    if($sth->rows)
    {
        print '<table border=0 width=100%>';
        while ($ref=$sth->fetchrow_hashref)
        {
            $n++;
            $bgcolor=&Syspkg::Rowcolor($n);
            $totalsum=$totalsum+$ref->{'SUM'};
            $totalcount=$totalcount+$ref->{'COUNT'};
            $ref->{'URL'}=~/(\/\d+\/\d+\/.*\/)/;
            print "<tr bgcolor=$bgcolor><td>$n</td><td>$1</td><td>$ref->{'SUM'}</td><td>$ref->{'COUNT'}</td></tr>\n";
        }
        $percent=($totalsum/$totalcount)*100;
        $percent=int($percent);
        print "<tr><td colspan=2 align=center><i>Total votes ($percent%)</i></td><td><b>$totalsum+</b></td><td><b>$totalcount</b></td></tr></table>\n";
    }
    else
    {
        print '<P align=center class=message>Данные за выбраный период отсутствуют.</P>';
    }
    return 1;
}

sub Disconnect()
{
    $ref=undef;
    $sth=undef;
    $dbh->disconnect;
    $dbh=undef;
    print '<P class=sysmsg>Connection close</P>';
}

return $module;
END;