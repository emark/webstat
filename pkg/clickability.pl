#Модуль статистики кликабельности постов
package Clickability;
use strict;
use constant VERSION=>1.05;

#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='Clickability';
my $modoption='';

BEGIN;

#Процедура инициализации модуля
#USAGE: $date_in,$date_out,$modoption(EXP,expand)
#EXP: URL, REFERER
sub Init()
{
    &main::HTMLDisplay;
    #pages - хеш страниц модуля. alias=>MODULE_NAME
    my %pages=('Shop URL'=>'URL',
               'Posts'=>'REFERER',
               ''=>'URL'#default page
               );
    my @modoption=('','','');
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
    print "<br>--<i>$modoption[0]</i>--";
    print '<br/>'.$modoption[2] if($modoption[2]);
    print '</P>';
    &QueryClickability($_[0],$_[1],$pages{$modoption[0]},$modoption[1],$modoption[2]);
    &Disconnect;
}

#Процедура подсчета кликабельности
#USAGE: $date_in,$date_out,$page(EXP),$expand || $show,FILTER
#EXP: URL, REFERER
sub QueryClickability()
{
    my $name='';
    my $n=0;
    my $bgcolor=0;
    my $totalclicks=0;
    my $rowlimit=20;#Ограничение на первичный вывод строк
    my %invert_pages=('URL'=>'Posts',
               'REFERER'=>'Shop URL');#Хеш для раскрытия группировки
    my %invert_types=('URL'=>'REFERER',
               'REFERER'=>'URL');
    my %domain=('URL'=>'http://',
                'REFERER'=>'http://www.web2buy.ru'
               );
    $SQL="SELECT $_[2],COUNT(URL) AS CLICKABILITY FROM URLSTAT WHERE LENGTH(REFERER)>0 AND DATE>='$_[0]' AND DATE<='$_[1]' ";
    if($_[3] eq 'open'){
        $SQL=$SQL." AND $invert_types{$_[2]}='$_[4]'";#Фильтрация по типу URL || REFERRER
    }
    $SQL=$SQL." GROUP BY $_[2] ORDER BY CLICKABILITY DESC";
    $sth=$dbh->prepare($SQL);#print $SQL;
    $sth->execute();
    if($sth->rows)
    {
        print '<table border=0 width=100%>';
        while ($ref=$sth->fetchrow_hashref)
        {
            $n++;
            $bgcolor=&Syspkg::Rowcolor($n);#Подсветка строк таблицы
            $name=substr($ref->{$_[2]},0,250);
            $name=~s/http:\/\/www\.web2buy\.ru//;#Удаляем имя хоста
            $totalclicks=$totalclicks+$ref->{'CLICKABILITY'};
            if($n<=$rowlimit || $_[3])
            {
                print "<tr bgcolor=$bgcolor><td>$n</td><td><a href=\"$domain{$_[2]}$ref->{$_[2]}\" target=_blank title='Open in new window'>$name</a>&nbsp;<a href=\"?date_in=$_[0]&date_out=$_[1]&module=$module&modoption=$invert_pages{$_[2]}:open:$ref->{$_[2]}\" target=_self title='Open'>+</a></td><td>$ref->{'CLICKABILITY'}</td></tr>\n";
            }
        }
        if(!$_[3] && $n>$rowlimit)#Если строк больше rowlimit, показыаем тег more
        {
            $n=$n-$rowlimit;
            print "<tr align=center><td colspan=2><a href=\"?date_in=$_[0]&date_out=$_[1]&module=$module&modoption=$modoption:expand\">more ($n)</a></td><td>...</td></tr>\n";
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
    &main::HTMLfinish;
}

return $module;
END;