#Company database manager
package Registry;
use strict;
use CGI qw/:standard/;
use constant VERSION=>0.3;

#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='Registry';
my @modoption='';

BEGIN;

#Процедура инициализации модуля
#USAGE: $date_in,$date_out,$modoption(url)
#EXP: URL, REFERER
sub Init()
{
    @modoption=@_;
    if($modoption[0] eq 'export' && @modoption>1) #Если выбран хотя бы один элемент
    {
        print header(-charset=>'UTF-8',
                     -type=>'text/plain',
                     -attachment=>'export.csv'
                     );
    }
    else
    {
        &main::HTMLDisplay;
        #print @modoption; #Developer mode
        my %pages=('check'=>'Check URL',
                   'export'=>'Export',
                   );
        my %pagetitle=('check'=>'Check URL', #Отображение в заголовке текущего действия
                   'export'=>'CSV export',
                   'save'=>'Save changes'
                   );
        print "<P align=center>";
        foreach my $key(keys %pages)
        {
            print "<a href=\"?module=$module&modoption=$key\">$pages{$key}</a>&nbsp";
        }
        print "<br><i>$pagetitle{$modoption[0]}</i></P>";
    }    
    #Connection with database
    $dbh=DBI->connect(&Syspkg::Static($::dbconf));
    $::dbconf=undef;
    $dbh->trace();
    if($modoption[0] eq 'check')
    {
        &CheckURLForm($modoption[1]);
    }
    elsif($modoption[0] eq 'save')
    {
        &SaveCompanyForm(@modoption)
    }
     elsif($modoption[0] eq 'export')
    {
        &ExportCSV(@modoption)
    }
    &Disconnect($modoption[0]);
    if($modoption[0] eq 'export' && @modoption>1)
    {
        #Export CSV
    }else
    {
        &main::HTMLfinish;        
    }
}

#Процедура экспорта данных реестра в формате CSV
sub ExportCSV()
{
    $SQL="SET NAMES UTF8";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    if(!$_[1]) #Первый запуск процедуры
    {
        $SQL="SELECT ID,URL FROM COMPANYREF ORDER BY ID";
        $sth=$dbh->prepare($SQL);
        $sth->execute;
        print start_form(-target=>'_blank');
        print hidden(-name=>'module',
                     -value=>$module);
        print hidden(-name=>'modoption',
                     -value=>'export');
        my $n=0;
        while ($ref=$sth->fetchrow_hashref)
        {
            $n++;
            print "$n. ";
            print checkbox(-name=>'modoption',
                           -value=>$ref->{'ID'},
                           -label=>''
                           );
            print "<a href=\"?module=$module&modoption=check&modoption=$ref->{'URL'}\">$ref->{'URL'}</a><br/>";
        }
        print submit(-value=>'Export');
        print end_form;
    }
    else
    {
        my @id=@_;
        shift @id;
        $SQL="SELECT ID,URL,EMAIL,TEL FROM COMPANYREF WHERE ID=0 ";
        foreach my $key(@id)
        {
            $SQL=$SQL." OR ID=$key";
        }
        $sth=$dbh->prepare($SQL);
        $sth->execute;#print $SQL;
        my $pnum=0;
        while ($ref=$sth->fetchrow_hashref)
        {
            print "<a href=\"http://www.web2buy.ru/link/?url=$ref->{'URL'}\" title='Переход в интернет-магазин' target=_blank>$ref->{'URL'}</a><P id=\"shopinfo-$pnum\"><a href=\"#1\" onClick=\"javascript:ShopInfo('$ref->{'URL'}','shopinfo-$pnum')\" title='ОГРН, условия доставки, оплаты'>Подробнее</a></P>;$ref->{'URL'};$ref->{'EMAIL'};$ref->{'TEL'}\n";
            $pnum++;
        }
    }
}

sub CheckURLForm()
{
    print start_form(-name=>'CheckURL',
                     -method=>'post');
    print '<input type=hidden name=modoption value=check>';
    print "<input type=text name=modoption size=25 value='$_[0]'>";
    print submit(-value=>'Check');
    print hidden(-name=>'module',
                 -value=>$module);
    print end_form();
    if($_[0])
    {
        &CheckURL($_[0]);
    }
}

#Процедура вывода регистрационной формы компании
#CompanyForm(%hash)
sub CompanyForm()
{
    #print @modoption;
    my %companyreg=@_;
    print start_form(-name=>'CompanyForm',
                     -method=>'post');
    print '<input type=hidden value=save name=modoption>';
    print "<input type=hidden value='$companyreg{'URL'}' name=modoption>";
    print '<table border=0>';
    print '<tr><td rowspan=2>';
    print "<input type=hidden name=modoption value=$companyreg{'ID'}>";
    print "<input type=text name=modoption value='$companyreg{'ORGANIZATION'}'>&nbsp;Наименование магазина (<a href=\"http://$companyreg{'URL'}\" target=_blank>weblink</a>)<br/>";
    print "<input type=text name=modoption value='$companyreg{'OGRN'}'>&nbsp;ОГРН&nbsp;";
    print '<br/>';
    print "<input type=text size=35 name=modoption value='$companyreg{'ADDRESS'}'>&nbsp;Адрес продавца<br/>";
    print "<input type=text size=35 name=modoption value='$companyreg{'FNAME'}'>&nbsp;Полное фирменное наименование<br/>";
    print "<input type=text size=35 name=modoption value='$companyreg{'TEL'}'>&nbsp;Контактный телефон<br/>";
    print "<input type=text name=modoption value='$companyreg{'EMAIL'}'>&nbsp;Эл. почта (<a href=\"mailto:$companyreg{'EMAIL'}\">сообщение</a>)<br/><hr width=100%>";
    print &SelectHTML($companyreg{'CONSPROP'}).'&nbsp;Основные свойства товара<br/>';
    print &SelectHTML($companyreg{'PRICEINFO'}).'&nbsp;Цена и условия приобретения<br/>';
    print &SelectHTML($companyreg{'DELIVERYINFO'}).'&nbsp;Информация о доставке<br/>';
    print &SelectHTML($companyreg{'GUARANTEE'}).'&nbsp;Гарантия, срок службы<br/>';
    print "<input type=text size=4 name=modoption value='$companyreg{'ACCEPT'}' title='Срок, в течение которого действует предложение о заключении договора.'>&nbsp;Срок акцепта<br/>";
    print &SelectHTML($companyreg{'CASHBACK'}).'&nbsp;Срок и порядок возврата (надл. кач.)<br/>';
    print "<input type=text size=4 name=modoption value='$companyreg{'GOODBACKDAYS'}' title='Срок возврата тов. надл.кач.'>&nbsp;Срок возврата товара<br/>";
    print "<input type=hidden name=modoption value=$companyreg{'SYSDATE'}>";
    print p("Дата регистрации (изменения): $companyreg{'SYSDATE'}");
    print '</td><td>';
    print p('Информация о доставке');
    print &SelectHTML($companyreg{'DT_MAIL'}).'&nbsp;Почта РФ<br/>';
    print &SelectHTML($companyreg{'DT_CC'}).'&nbsp;Курьерские компании<br/>';
    print &SelectHTML($companyreg{'DT_TC'}).'&nbsp;Транспортные компании<br/>';
    print &SelectHTML($companyreg{'DT_CR'}).'&nbsp;Курьер<br/>';
    print &SelectHTML($companyreg{'DT_PP'}).'&nbsp;Самовывоз<br/>';
    print '</td></tr><tr><td>';
    print p('Информация об оплате');
    print &SelectHTML($companyreg{'PT_BP'}).'&nbsp;Банковский платеж<br/>';
    print &SelectHTML($companyreg{'PT_EM'}).'&nbsp;Электронные деньги<br/>';
    print &SelectHTML($companyreg{'PT_CH'}).'&nbsp;Платеж наличными<br/>';
    print &SelectHTML($companyreg{'PT_PM'}).'&nbsp;Наложенный платеж<br/>';
    print &SelectHTML($companyreg{'PT_BC'}).'&nbsp;Банковские карты<br/>';
    print &SelectHTML($companyreg{'PT_TP'}).'&nbsp;Терминалы оплаты<br/>';
    print '</td></tr><tr><td colspan=2 align=left>';
    print "<input type=text size=60 name=modoption value=\"$companyreg{'TAGS'}\">&nbsp;Метки магазина<br/>";
    print '</td></tr><tr><td colspan=2 align=left>';
    print submit(-value=>'Save changes');
    print '</td></tr></table>';
    print hidden(-name=>'module',
                 -value=>$module);
    print end_form;
}

#Процедура печати HTML тега SELECT
sub SelectHTML()
{
    my @selected=('false','selected');
    my $select="<select name=modoption><option value='0' $selected[$_[0]]>&nbsp;&nbsp;X&nbsp;&nbsp;<option value='1' $selected[$_[0]]>&nbsp;&nbsp;V&nbsp;&nbsp;</select>";
    return $select;
}

#Процедура сохранения данных регистрационной формы
sub SaveCompanyForm()
{
    my @companyreg=@_;
    my $n=0;
    print "\n<!--Developer mode\n";
    foreach my $key(@companyreg)
    {
        print "$n\t$key\t\n";
        $n++
    }
    my $count=@_;
    print $n;
    print $count.'-->';
    
    $SQL="SET NAMES UTF8";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    
    if($_[2])#ID существует
    {
        $SQL="UPDATE COMPANYREF
        SET `ORGANIZATION`='$_[3]',
         `OGRN`='$_[4]',
         `ADDRESS`='$_[5]',
         `FNAME`='$_[6]',
         `TEL`='$_[7]',
         `EMAIL`='$_[8]',
         `CONSPROP`=$_[9],
         `PRICEINFO`=$_[10],
         `DELIVERYINFO`=$_[11],
         `GUARANTEE`=$_[12],
         `ACCEPT`=$_[13],
         `CASHBACK`=$_[14],
          `GOODBACKDAYS`=$_[15],
         `SYSDATE`=NOW(),
         `DT_MAIL`=$_[17],
         `DT_CC`=$_[18],
         `DT_TC`=$_[19],
          `DT_CR`=$_[20],
          `DT_PP`=$_[21],
          `PT_BP`=$_[22],
          `PT_EM`=$_[23],
          `PT_CH`=$_[24],
          `PT_PM`=$_[25],
          `PT_BC`=$_[26],
          `PT_TP`=$_[27],
          `TAGS`=\"$_[28]\" 
        WHERE ID=$_[2]";
    }
    else
    {
        $SQL="INSERT INTO COMPANYREF(`URL`,`ORGANIZATION`, `OGRN`,`ADDRESS`, `FNAME`,`TEL`,`EMAIL`,`CONSPROP`, `PRICEINFO`, `DELIVERYINFO`, `GUARANTEE`, `ACCEPT`, `CASHBACK`,
        `GOODBACKDAYS`,`SYSDATE`,  `DT_MAIL`, `DT_CC`, `DT_TC`, `DT_CR`, `DT_PP`, `PT_BP`, `PT_EM`, `PT_CH`, `PT_PM`, `PT_BC`, `PT_TP`,`TAGS`)
        VALUES('$_[1]','$_[3]','$_[4]','$_[5]','$_[6]','$_[7]','$_[8]',$_[9],$_[10],$_[11],$_[12],$_[13],$_[14],$_[15],NOW(),$_[17],$_[18],$_[19],$_[20],$_[21],$_[22],$_[23],
        $_[24],$_[25],$_[26],$_[27],\"$_[28]\")";
    }
    #print $SQL;
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    print p({-align=>'center'},"Registry information about $_[3] ($_[1]) is saved.");
    print p({-align=>'center'},"Would you like to <a href=\"?module=$module&modoption=check&modoption=$_[1]\">see</a> it or <a href=\"?module=$module&modoption=check\">search</a> another url?");
    return 1;
}

#Процедура проверка существования URL
sub CheckURL()
{
    my @status=('False','Ok');
    my %companyreg=('URL'=>$_[0]);
    $SQL="SET NAMES UTF8";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    $SQL="SELECT `ID`, `ORGANIZATION`, `URL`, `OGRN`, `CONSPROP`, `ADDRESS`, `FNAME`, `PRICEINFO`, `DELIVERYINFO`, `GUARANTEE`, `ACCEPT`, `CASHBACK`,`GOODBACKDAYS`,
    `SYSDATE`, `TEL`,`EMAIL`, `DT_MAIL`, `DT_CC`, `DT_TC`, `DT_CR`, `DT_PP`, `PT_BP`, `PT_EM`, `PT_CH`, `PT_PM`, `PT_BC`, `PT_TP`, TAGS FROM COMPANYREF WHERE URL='$_[0]'";
    $sth=$dbh->prepare($SQL);#print $SQL;
    $sth->execute();
    print "<PRE>Checked: $status[$sth->rows]</PRE>";
    if($sth->rows())
    {
        while($ref=$sth->fetchrow_hashref)
        {
            for(my $n=0;$n<=27;$n++)
            {
                $companyreg{$sth->{'NAME'}->[$n]}=$ref->{$sth->{'NAME'}->[$n]};
            }
        }
    }
    return &CompanyForm(%companyreg);
}

sub Disconnect()
{
    $ref=undef;
    $sth=undef;
    $dbh->disconnect;
    $dbh=undef;
    if($_[0] eq 'export')
    {
        #Export CSV format
    }
    else
    {
        print '<P class=sysmsg>Connection close</P>';        
    }
}

return $module;
END;