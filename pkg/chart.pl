#Модуль визуализации данных используя API Google Chart
#Create with http://imagecharteditor.appspot.com/
package Chart;
use strict;
use constant VERSION=>0.6;

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
               'CPM'=>'CpM',
               'CPD'=>'CpD',
               'CPH'=>'CpH',
               'UPM'=>'UpM',
               'UPD'=>'UpD',
               'UPH'=>'UpH',
               ''=>'CpH'#default page
               );
    my @sortpages=('CPH','CPD','CPM','UPH','UPD','UPM');#Sorting pages
    my @modoption=('','');
    if($_[2])
    {
        @modoption=split (/:/,$_[2]);
        $modoption=$_[2];#Определяем глобальную переменную    
    }    
    $dbh=DBI->connect(&Syspkg::Static($::dbconf));
    $::dbconf=undef;#For close warning
    $dbh->trace();
    print "<P align=center>";
    foreach my $key(@sortpages)
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
    my $var='';
    my $maxvalue=0;#for define axis  value
    my $totalvar=0;
    my $labelx='';#Label value for x axis
    my %SQL_SRC=('Loyalty'=>"SELECT MONTH(DATE),SUM(IF(ANSWER>0,1,0)),COUNT(ANSWER) FROM POSTSTAT WHERE DATE>='$_[0]' AND DATE<='$_[1]' GROUP BY MONTH(DATE) ORDER BY DATE",
                 'CpM'=>"SELECT MONTH(DATE), COUNT(URL) FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY MONTH(DATE) ORDER BY DATE",
                 'CpD'=>"SELECT DAY(DATE) AS DAY,COUNT(IP) FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY DAY ORDER BY DAY",
                 'CpH'=>"SELECT HOUR(DATE) AS HOUR,COUNT(IP) FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY HOUR ORDER BY HOUR",
                 'UpM'=>"SELECT DATE,SUM(IP) FROM (SELECT MONTH(DATE) AS DATE,1 AS IP FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY IP) AS T1 GROUP BY DATE ORDER BY DATE",
                 'UpD'=>"SELECT DATE,SUM(IP) FROM (SELECT DAY(DATE) AS DATE,1 AS IP FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY IP) AS T1 GROUP BY DATE ORDER BY DATE",
                 'UpH'=>"SELECT DATE,SUM(IP) FROM (SELECT HOUR(DATE) AS DATE,1 AS IP FROM URLSTAT WHERE LENGTH(REFERER)>0 AND (DATE>='$_[0]' AND DATE<='$_[1]') GROUP BY IP) AS T1 GROUP BY DATE ORDER BY DATE",
                );
    $sth=$dbh->prepare($SQL_SRC{$_[2]});
    #print $SQL_SRC{$_[2]};
    $sth->execute;
    print "<pre>Date\tData\n";
    while ($ref=$sth->fetchrow_arrayref)
    {
        print "$ref->[0]\t$ref->[1]\n"; #Display data
        $var=$var."$ref->[1],";
        $totalvar=$totalvar+$ref->[1];
        $maxvalue=$ref->[1] if $ref->[1]>$maxvalue;
        $labelx=$labelx."$ref->[0]|";
    }
    print "---\nTotal\t$totalvar";
    chop $var;
    #Заполнение графиков данными
    my %IMG_SRC=('CpM'=>"http://chart.apis.google.com/chart?chxl=1:|$labelx&chxr=0,0,$maxvalue&chxt=y,x&chs=720x400&cht=lc&chco=3D7930&chds=0,$maxvalue&chd=t:$var&chg=14.3,-1,1,1&chls=1&chm=B,C5D4B5BB,0,0,0&chtt=Data+for+$_[2]",
                 'CpD'=>"http://chart.apis.google.com/chart?chxl=1:|$labelx&chxr=0,0,$maxvalue&chxt=y,x&chbh=a&chs=720x400&cht=bvg&chco=A2C180&chds=0,$maxvalue&chd=t:$var&chtt=Data+for+$_[2]",
                 'CpH'=>"http://chart.apis.google.com/chart?chxl=1:|$labelx&chxr=0,0,$maxvalue&chxt=y,x&chbh=a&chs=720x400&cht=bvg&chco=A2C180&chds=0,$maxvalue&chd=t:$var&chtt=Data+for+$_[2]",
                 'UpM'=>"http://chart.apis.google.com/chart?chxl=1:|$labelx&chxr=0,0,$maxvalue&chxt=y,x&chs=720x400&cht=lc&chco=00799B&chds=0,$maxvalue&chd=t:$var&chg=14.3,-1,1,1&chls=1&chm=B,ADDDEABB,0,0,0&chtt=Data+for+$_[2]",
                 'UpD'=>"http://chart.apis.google.com/chart?chxl=1:|$labelx&chxr=0,0,$maxvalue&chxt=y,x&chbh=a&chs=720x400&cht=bvg&chco=00ACDC&chds=0,$maxvalue&chd=t:$var&chtt=Data+for+$_[2]",
                 'UpH'=>"http://chart.apis.google.com/chart?chxl=1:|$labelx&chxr=0,0,$maxvalue&chxt=y,x&chbh=a&chs=720x400&cht=bvg&chco=00ACDC&chds=0,$maxvalue&chd=t:$var&chtt=Data+for+$_[2]",
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
