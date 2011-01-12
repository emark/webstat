#Модуль статистики голосований постов *Лояльность*
package Loyalty;
use strict;
use constant VERSION=>1.07;

#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='Loyalty';
my $modoption='';

BEGIN;

sub Init()
{
    my @modoption=('','');
    if($_[2])
    {
        @modoption=split (/:/,$_[2]);
        $modoption=$_[2];#Определяем глобальную переменную    
    }  
    #Connection with database
    $dbh=DBI->connect(&Syspkg::DBconf);
    $dbh->trace();
    &QueryTopList($_[0],$_[1],$modoption[1]);
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
    my $rowlimit=10;#Ограничение на первичный вывод строк
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
            if($ref->{'SUM'}>0)#Учитываем только положительные голоса
            {
                $totalsum=$totalsum+$ref->{'SUM'};
            }
            $totalcount=$totalcount+$ref->{'COUNT'};
            $ref->{'URL'}=~/(\/\d+\/\d+\/.*\/)/;
             if($n<=$rowlimit || $_[2])
            {
                print "<tr bgcolor=$bgcolor><td>$n</td><td>$1</td><td>$ref->{'SUM'}</td><td>$ref->{'COUNT'}</td></tr>\n";
            }
        }
        if(!$_[2] && $n>$rowlimit)#Если строк меньше rowlimit, не показыаем тег more
        {
            $n=$n-$rowlimit;
            print "<tr align=center><td colspan=2><a href=\"?date_in=$_[0]&date_out=$_[1]&module=$module&modoption=$modoption:expand\">more ($n)</a></td><td colspan=2>...</td></tr>\n";
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