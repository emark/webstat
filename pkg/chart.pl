#Модуль визуализации данных используя API Google Chart
package Chart;
use strict;
use constant VERSION=>0.01;

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
    #pages - хеш страниц модуля. alias=>MODULE_NAME
    my %pages=('Loyalty'=>'POSTSTAT',
               'Clickability'=>'URLSTAT',
               ''=>'POSTSTAT'#default page
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
    &BuildChart($_[0],$_[1],$pages{$modoption[0]},$modoption[1]);
    &Disconnect;
}

#Процедура визуализации данных 
sub BuildChart()
{
    my $sum='';
    my $count='';
    my $start_month='';
    my $finish_month='';
    #my %RANGE=('POSTSTAT'=>"COUNT(ANSWER) AS ANSWERCOUNT, SUM(ANSWER) AS ANSWERSUM FROM POSTSTAT WHERE DATE>='$_[0]' AND DATE<='$_[1]'",
    #         'URLSTAT'=>"COUNT(URL) AS URLCOUNT FROM URLSTAT WHERE LENGTH(REFERER)>0 AND DATE>='$_[0]' AND DATE<='$_[1]'",
    #         );
    #$SQL="SELECT DATE_FORMAT(DATE,\'%Y-%m-%d\') AS FDATE, $RANGE{$_[2]} GROUP BY FDATE";
    $SQL="SELECT MONTH(DATE),SUM(ANSWER),COUNT(ANSWER) FROM POSTSTAT GROUP BY MONTH(DATE)";
    $sth=$dbh->prepare($SQL);#print $SQL;
    $sth->execute;
    print '<pre>';
    while ($ref=$sth->fetchrow_arrayref)
    {
        #print "$ref->[0]\t$ref->[1]\t$ref->[2]\n";
        $sum=$sum."$ref->[1],";
        $count=$count."$ref->[2],";
        if(!$start_month)
        {
            $start_month=$ref->[0];
        }
        else
        {
            $finish_month=$ref->[0];
        }
    }
    chop $sum;
    chop $count;
    print '</pre><center>';
    print "<img src=\"http://chart.apis.google.com/chart?chxr=2,$start_month,$finish_month&chxt=y,r,x&chbh=a,7&chs=500x325&cht=bvg&chco=A2C180,3D7930&chd=t:$sum|$count&chg=5,5,0,0&chtt=Vertical+bar+chart\" width=\"500\" height=\"325\" alt=\"Vertical bar chart\" />";
    #print "<img src=\"http://chart.apis.google.com/chart?chxr=2,$start_month,$finish_month&chxt=y,r,x&chbh=a,7&chs=500x325&cht=lc&chco=A2C180,3D7930&chd=t:$sum|$count&chg=5,5,0,0&chtt=Vertical+bar+chart\" width=\"500\" height=\"325\" alt=\"Vertical bar chart\" />";
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
