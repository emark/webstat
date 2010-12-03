#Модуль статистики кликабельности постов
package UrlStat;
use strict;
use constant VERSION=>1.05;

#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='Clickability';
my $modoption=0;

BEGIN;

#Процедура инициализации модуля
#USAGE: $date_in,$date_out,$modoption(EXP,expand)
#EXP: URL, REFERER
sub Init()
{
    #pages - хеш страниц модуля. alias=>MODULE_NAME
    my %pages=('Shop URL'=>'URL',
               'Posts'=>'REFERER',
               ''=>'URL'#default page
               );
    my @modoption=('','');
    if($_[2])
    {
        @modoption=split (/:/,$_[2]);
        $modoption=$_[2];#Определяем глобальную переменную    
    }    
    $dbh=DBI->connect(&Syspkg::DBconf);
    $dbh->trace();
    print "<P align=center>";
    foreach my $key(keys %pages)
    {
        print "<a href=\"?date_in=$_[0]&date_out=$_[1]&module=$module&modoption=$key\">$key</a>&nbsp";
    }
    print "<br>--<i>$modoption[0]</i>--</P>";
    &QueryClickability($_[0],$_[1],$pages{$modoption[0]},$modoption[1]);
    &Disconnect;
}
#Процедура подсчета кликабельности
#USAGE: $date_in,$date_out,$page(EXP),$expand
#EXP: URL, REFERER
sub QueryClickability()
{
    my $name='';
    my $n=0;
    my $bgcolor=0;
    my $totalclicks=0;
    my %domain=('URL'=>'http://',
                'REFERER'=>'http://www.web2buy.ru'
               );
    $SQL="SELECT $_[2],COUNT(URL) AS CLICKABILITY FROM URLSTAT WHERE LENGTH(REFERER)>0 AND DATE>='$_[0]' AND DATE<='$_[1]'
            GROUP BY $_[2] ORDER BY CLICKABILITY DESC";
    $sth=$dbh->prepare($SQL);#print $SQL;
    $sth->execute();
    if($sth->rows)
    {
        print '<table border=0 width=100%>';
        while ($ref=$sth->fetchrow_hashref)
        {
            $n++;
            $bgcolor=&Syspkg::Rowcolor($n);
            $name=substr($ref->{$_[2]},0,250);
            $totalclicks=$totalclicks+$ref->{'CLICKABILITY'};
            if($n<=20 || $_[3])
            {
                print "<tr bgcolor=$bgcolor><td>$n</td><td><a href=\"$domain{$_[2]}$ref->{$_[2]}\" target=_blank>$name</a></td><td>$ref->{'CLICKABILITY'}</td></tr>\n";
            }
        }
        if(!$_[3])
        {
            print "<tr align=center><td colspan=2><a href=\"?date_in=$_[0]&date_out=$_[1]&module=$module&modoption=$modoption:expand\">more...</a></td><td>...</td></tr>\n";
        }
        print "<tr><td colspan=2 align=center><i>Total clicks</i></td><td><b>$totalclicks</b></td></tr></table>\n";    }
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