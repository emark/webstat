#Модуль визуализации данных используя API Google Chart
#Create with http://imagecharteditor.appspot.com/
package Chart;
use strict;
use constant VERSION=>0.5;

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
    &main::HTMLDisplay;
    #pages - инициализация страниц модуля. alias=>MODULE_NAME
    my %pages=(
               'Clicks by month'=>'CbM',
               'Clicks by hour'=>'CbH',
               'Clicks by day'=>'CbD',
               ''=>'Clickability'#default page
               );
    my @modoption=('','');
    if($_[2])
    {
        @modoption=split (/:/,$_[2]);
        $modoption=$_[2];#Определяем глобальную переменную    
    }    
    $dbh=DBI->connect(&Syspkg::Static($main::dbconf));
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
#Pages: Loyalty, Clickability, Ubh, Ubd
sub BuildChart()
{
    my $var1='';
    my $var2='';
    my $maxvalue=0;#for define axis  value
    my $totalvar1=0;
    my $totalvar2=0;
    my $labelx='';#Label value for x axis
    my %SQL_SRC=('Loyalty'=>"SELECT MONTH(DATE),SUM(IF(ANSWER>0,1,0)),COUNT(ANSWER) FROM POSTSTAT WHERE DATE>='$_[0]' AND DATE<='$_[1]' GROUP BY MONTH(DATE) ORDER BY DATE",
                 'CbM'=>"SELECT MONTH(DATE), COUNT(URL), COUNT(REFERER) FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY MONTH(DATE) ORDER BY DATE",
                 'CbH'=>"SELECT HOUR(DATE) AS HOUR,COUNT(IP),0 FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY HOUR ORDER BY HOUR",
                 'CbD'=>"SELECT DAY(DATE) AS DAY,COUNT(IP),0 FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY DAY ORDER BY DAY"
                );
    $sth=$dbh->prepare($SQL_SRC{$_[2]});print $SQL_SRC{$_[2]};
    $sth->execute;
    print "<pre>Date\tData1\tData2\n";
    while ($ref=$sth->fetchrow_arrayref)
    {
        print "$ref->[0]\t$ref->[1]\t$ref->[2]\n"; #Display data
        $var1=$var1."$ref->[1],";
        $totalvar1=$totalvar1+$ref->[1];
        $var2=$var2."$ref->[2],";
        $maxvalue=$ref->[1] if $ref->[1]>$maxvalue;
        $labelx=$labelx."$ref->[0]|";
    }
    print "------\nTotal\t$totalvar1\t$totalvar2";
    chop $var1;
    chop $var2;
    #Заполнение графиков данными
    my %IMG_SRC=('CbM'=>"http://chart.apis.google.com/chart?chxl=1:|$labelx&chxr=0,0,$maxvalue&chxt=y,x&chs=500x325&cht=lc&chco=3D7930&chds=0,$maxvalue&chd=t:$var1&chg=14.3,-1,1,1&chls=1&chm=B,C5D4B5BB,0,0,0&chtt=Data+for+$_[2]\" width=\"500\" height=\"325\" alt=\"Clickability\"",
                 'CbH'=>"http://chart.apis.google.com/chart?chxl=1:|$labelx&chxr=0,0,$maxvalue&chxt=y,x&chbh=a&chs=500x325&cht=bvg&chco=A2C180&chds=0,$maxvalue&chd=t:$var1&chtt=Data+for+$_[2]",
                 'CbD'=>"http://chart.apis.google.com/chart?chxl=1:|$labelx&chxr=0,0,$maxvalue&chxt=y,x&chbh=a&chs=500x325&cht=bvg&chco=A2C180&chds=0,$maxvalue&chd=t:$var1&chtt=Data+for+$_[2]",
                );
    print '</pre><center>';
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
    &main::HTMLfinish;
}

return $module;
END;
