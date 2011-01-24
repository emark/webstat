#Company database manager
package ComReg;
use strict;
use CGI qw/:standard/;
use constant VERSION=>0.1;

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
    #print @_;
    #my @modoption=('','');
    #if($_[2])
    #{
        #@modoption=split (/:/,$_[2]);
        #$modoption=@_;#Определяем глобальную переменную    
    #}  
    #Connection with database
    @modoption=@_;
    $dbh=DBI->connect(&Syspkg::DBconf);
    $dbh->trace();
    if(@modoption<=1)
    {
        &CheckURLForm($modoption[0]);
    }
    else
    {
        &SaveCompanyForm(@modoption)
    }
    &Disconnect;
}

sub CheckURLForm()
{
    print start_form(-method=>'post');
    print textfield(-name=>'modoption',
                    -size=>25,
                    -value=>'',
                    -default=>'www.'.$_[0]
                    );
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
    print start_form(-method=>'post');
    print hidden(-name=>'modoption',
                 -value=>"$_[0]->{'URL'}");
    print '<table border=0>';
    print '<tr><td rowspan=2>';
    #print p("ID: $_[0]->{'ID'}");
    print "<input type=hidden name=modoption value=$_[0]->{'ID'}>";
    print "<input type=text name=modoption value='$_[0]->{'ORGANIZATION'}'>&nbsp;Наименование магазина<br/>";
    print "<input type=text name=modoption value='$_[0]->{'OGRN'}'>&nbsp;ОГРН&nbsp;";
    #if($_[0]->{'OGRN'})#Просмотр сведений на сайте ИФНС
    #{
        #print "<a href=\"http://egrul.nalog.ru/fns/\" target=_blank>Данные ИФНС</a>";
    #}
    print '<br/>';
    print "<input type=text size=35 name=modoption value='$_[0]->{'ADDRESS'}'>&nbsp;Адрес продавца<br/>";
    print "<input type=text size=35 name=modoption value='$_[0]->{'FNAME'}'>&nbsp;Полное фирменное наименование<br/>";
    print "<input type=text name=modoption value='$_[0]->{'EMAIL'}'>&nbsp;Эл. почта<br/><hr width=100%>";
    print &SelectHTML($_[0]->{'CONSPROP'}).'&nbsp;Основные свойства товара<br/>';
    print &SelectHTML($_[0]->{'PRICEINFO'}).'&nbsp;Цена и условия приобретения<br/>';
    print &SelectHTML($_[0]->{'DELIVERYINFO'}).'&nbsp;Информация о доставке<br/>';
    print &SelectHTML($_[0]->{'GUARANTEE'}).'&nbsp;Гарантия, срок службы<br/>';
    print "<input type=text size=4 name=modoption value='$_[0]->{'ACCEPT'}' title='Срок, в течение которого действует предложение о заключении договора.'>&nbsp;Срок акцепта<br/>";
    print &SelectHTML($_[0]->{'CASHBACK'}).'&nbsp;Срок и порядок возврата (надл. кач.)<br/>';
    print "<input type=text size=4 name=modoption value='$_[0]->{'GOODBACKDAYS'}' title='Срок возврата тов. надл.кач.'>&nbsp;Срок возврата товара<br/>";
    print "<input type=hidden name=modoption value=$_[0]->{'SYSDATE'}>";
    print p("Дата регистрации (изменения): $_[0]->{'SYSDATE'}");
    print '</td><td>';
    print p('Информация о доставке');
    print &SelectHTML($_[0]->{'DT_MAIL'}).'&nbsp;Почта РФ<br/>';
    print &SelectHTML($_[0]->{'DT_CC'}).'&nbsp;Курьерские компании<br/>';
    print &SelectHTML($_[0]->{'DT_TC'}).'&nbsp;Транспортные компании<br/>';
    print &SelectHTML($_[0]->{'DT_CR'}).'&nbsp;Курьер<br/>';
    print &SelectHTML($_[0]->{'DT_PP'}).'&nbsp;Самовывоз<br/>';
    print '</td></tr><tr><td>';
    print p('Информация об оплате');
    print &SelectHTML($_[0]->{'PT_BP'}).'&nbsp;Банковский платеж<br/>';
    print &SelectHTML($_[0]->{'PT_EM'}).'&nbsp;Электронные деньги<br/>';
    print &SelectHTML($_[0]->{'PT_CH'}).'&nbsp;Платеж наличными<br/>';
    print &SelectHTML($_[0]->{'PT_PM'}).'&nbsp;Наложенный платеж<br/>';
    print &SelectHTML($_[0]->{'PT_BC'}).'&nbsp;Банковские карты<br/>';
    print &SelectHTML($_[0]->{'PT_TP'}).'&nbsp;Терминалы оплаты<br/>';
    print '</td></tr><tr><td colspan=2 align=center>';
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
    
    if($_[1])#ID существует
    {
        $SQL="UPDATE COMPANYREF
        SET `ORGANIZATION`='$_[2]',
         `OGRN`='$_[3]',
         `ADDRESS`='$_[4]',
         `FNAME`='$_[5]',
         `EMAIL`='$_[6]',
         `CONSPROP`=$_[7],
         `PRICEINFO`=$_[8],
         `DELIVERYINFO`=$_[9],
         `GUARANTEE`=$_[10],
         `ACCEPT`=$_[11],
         `CASHBACK`=$_[12],
          `GOODBACKDAYS`=$_[13],
         `SYSDATE`=NOW(),
         `DT_MAIL`=$_[15],
         `DT_CC`=$_[16],
         `DT_TC`=$_[17],
          `DT_CR`=$_[18],
          `DT_PP`=$_[19],
          `PT_BP`=$_[20],
          `PT_EM`=$_[21],
          `PT_CH`=$_[22],
          `PT_PM`=$_[23],
          `PT_BC`=$_[24],
          `PT_TP`=$_[25] 
        WHERE ID=$_[1]";
    }
    else
    {
        $SQL="INSERT INTO COMPANYREF(`URL`,`ORGANIZATION`, `OGRN`,`ADDRESS`, `FNAME`,`EMAIL`,`CONSPROP`, `PRICEINFO`, `DELIVERYINFO`, `GUARANTEE`, `ACCEPT`, `CASHBACK`,
        `GOODBACKDAYS`,`SYSDATE`,  `DT_MAIL`, `DT_CC`, `DT_TC`, `DT_CR`, `DT_PP`, `PT_BP`, `PT_EM`, `PT_CH`, `PT_PM`, `PT_BC`, `PT_TP`)
        VALUES('$_[0]','$_[2]','$_[3]','$_[4]','$_[5]','$_[6]',$_[7],$_[8],$_[9],$_[10],$_[11],$_[12],$_[13],NOW(),$_[15],$_[16],$_[17],$_[18],$_[19],$_[20],$_[21],$_[22],
        $_[23],$_[24],$_[25])";
    }
    #print $SQL;
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    print p({-align=>'center'},"Registry information about $_[2] ($_[0]) is saved.");
    print p({-align=>'center'},"Would you like to <a href=\"?module=$module&modoption=$_[0]\">see</a> it or <a href=\"?module=$module\">search</a> another url?");
    return 1;
}

#Процедура проверка существования URL
sub CheckURL()
{
    my @status=('False','Ok');
    $SQL="SET NAMES UTF8";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    $SQL="SELECT `ID`, `ORGANIZATION`, `URL`, `OGRN`, `CONSPROP`, `ADDRESS`, `FNAME`, `PRICEINFO`, `DELIVERYINFO`, `GUARANTEE`, `ACCEPT`, `CASHBACK`,`GOODBACKDAYS`,
    `SYSDATE`, `EMAIL`, `DT_MAIL`, `DT_CC`, `DT_TC`, `DT_CR`, `DT_PP`, `PT_BP`, `PT_EM`, `PT_CH`, `PT_PM`, `PT_BC`, `PT_TP` FROM COMPANYREF WHERE URL='$_[0]'";
    $sth=$dbh->prepare($SQL);#print $SQL;
    $sth->execute();
    print "<PRE>Checked: $status[$sth->rows]</PRE>";
    return &CompanyForm($sth->fetchrow_hashref);
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