#Модуль статистики кликабельности постов
package UrlStat;
use strict;
use constant VERSION=>1.04;

#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='Clickability';

BEGIN;

#Процедура инициализации модуля
#USAGE: $date_in,$date_out,$modoption(EXP)
#EXP: URL, REFERER
sub Init()
{
    #Connection with database
    #pages - хеш страниц модуля. alias=>MODULE_NAME
    my %pages=('Shop URL'=>'URL',
               'Posts'=>'REFERER',
               ''=>'URL'#default page
               );
    $dbh=DBI->connect(&Syspkg::DBconf);
    $dbh->trace();
    print "<P align=center><i>$_[2]</i></P>\n";
    foreach my $key(keys %pages)
    {
        print "<a href=\"?date_in=$_[0]&date_out=$_[1]&module=$module&modoption=$key\">$key</a>&nbsp";
    }
    &QueryClickability($_[0],$_[1],$pages{$_[2]});
    &Disconnect;
}
#Процедура подсчета кликабельности
#USAGE: $date_in,$date_out,$page(EXP)
#EXP: URL, REFERER
sub QueryClickability()
{
    my $name='';
    my $n=0;
    my $totalclicks=0;
    my %domain=('URL'=>'http://',
                'REFERER'=>'http://www.web2buy.ru'
               );
    $SQL="SELECT $_[2],COUNT(URL) AS CLICKABILITY FROM URLSTAT WHERE LENGTH(REFERER)>0 AND DATE>='$_[0]' AND DATE<='$_[1]'
            GROUP BY $_[2] ORDER BY CLICKABILITY DESC LIMIT 20";
    $sth=$dbh->prepare($SQL);#print $SQL;
    $sth->execute();
    if($sth->rows)
    {
        print '<table border=1 width=100%>';
        while ($ref=$sth->fetchrow_hashref)
        {
            $n++;
            $name=substr($ref->{$_[2]},0,250);
            $totalclicks=$totalclicks+$ref->{'CLICKABILITY'};
            print "<tr><td>$n</td><td><a href=\"$domain{$_[2]}$ref->{$_[2]}\" target=_blank>$name</a></td><td>$ref->{'CLICKABILITY'}</td></tr>\n";
        }
        print "<tr><td colspan=2 align=center><i>Total clicks</i></td><td><b>$totalclicks</b></td></tr></table>\n";
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