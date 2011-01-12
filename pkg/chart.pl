#Модуль визуализации данных используя API Google Chart
#Create with http://imagecharteditor.appspot.com/
package Chart;
use strict;
use constant VERSION=>0.4;

#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='Charts';
my $modoption='';

BEGIN;

#Процедура инициализации модуля
#USAGE: $date_in,$date_out,$modoption(EXP,expand)
#EXP: URL, REFERER
sub Init()
{
    #pages - инициализация страниц модуля. alias=>MODULE_NAME
    my %pages=('Loyalty'=>'Loyalty',
               'Clickability'=>'Clickability',
               ''=>'Loyalty'#default page
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
    &BuildChart($_[0],$_[1],$pages{$modoption[0]});
    &Disconnect;
}

#Процедура визуализации данных
#USAGE: $date_in,$date_out,$modoption(page)
#Pages: Loyalty, Clickability
sub BuildChart()
{
    my $var1='';
    my $var2='';
    my $start_month='';
    my $finish_month='';
    my %SQL_SRC=('Loyalty'=>"SELECT MONTH(DATE),SUM(IF(ANSWER>0,1,0)),COUNT(ANSWER) FROM POSTSTAT WHERE DATE>='$_[0]' AND DATE<='$_[1]' GROUP BY MONTH(DATE) ORDER BY DATE",
                 'Clickability'=>"SELECT MONTH(DATE), COUNT(URL), COUNT(REFERER) FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY MONTH(DATE) ORDER BY DATE"
                );
    $sth=$dbh->prepare($SQL_SRC{$_[2]});#print $SQL_SRC{$_[2]};
    $sth->execute;
    while ($ref=$sth->fetchrow_arrayref)
    {
        #print "<pre>$ref->[0]\t$ref->[1]\t$ref->[2]\n</pre>"; #Display data
        $var1=$var1."$ref->[1],";
        $var2=$var2."$ref->[2],";
        if(!$start_month)#Устанавливаем начало и окончание периода для оси X
        {
            $start_month=$ref->[0];
        }
        else
        {
            $finish_month=$ref->[0];
        }
    }
    chop $var1;
    chop $var2;
    #Заполнение графиков данными
    my %IMG_SRC=('Loyalty'=>"http://chart.apis.google.com/chart?chxr=2,$start_month,$finish_month&chxt=y,r,x&chbh=a,7&chs=500x325&cht=bvg&chco=A2C180,3D7930&chd=t:$var1|$var2&chg=5,5,0,0&chtt=Data+for+Loyalty\" width=\"500\" height=\"325\" alt=\"Loyalty\"",
                 'Clickability'=>"http://chart.apis.google.com/chart?chxr=0,0,6000|1,$start_month,$finish_month&chxt=y,x&chs=500x325&cht=lc&chco=A2C180&chds=0,6000&chd=t:$var1&chg=5,5,0,0&chls=3&chm=o,008000,0,0:12:1,5&chtt=Data+for+Clickability\" width=\"500\" height=\"325\" alt=\"Clickability\""
                );
    print '<center>Warning: use only complete year period!<br>';
    print '<img src="';
    print $IMG_SRC{$_[2]};
    print '"/>';
    print '<P ALIGN=center><a href="';
    print $IMG_SRC{$_[2]};
    print '" target=_blank>Open chart</a></P>';
    print '</center>';
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
