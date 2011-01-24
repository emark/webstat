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
my $modoption='';

BEGIN;

#Процедура инициализации модуля
#USAGE: $date_in,$date_out,$modoption(url,expand)
#EXP: URL, REFERER
sub Init()
{
    print @_;
    my @modoption=('','');
    if($_[2])
    {
        @modoption=split (/:/,$_[2]);
        $modoption=$_[2];#Определяем глобальную переменную    
    }  
    #Connection with database
    $dbh=DBI->connect(&Syspkg::DBconf);
    $dbh->trace();
    &CheckURLForm($modoption[0]);
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
    my @checked=('','checked');
    print start_form(-method=>'get');
    print hidden(-name=>'modoption',
                 -value=>"$_[0]->{'URL'}");
    print '<table border=0>';
    print '<tr><td rowspan=2>';
    print p("ID: $_[0]->{'ID'}");
    print "<input type=text name=modoption value='$_[0]->{'ORGANIZATION'}'>&nbsp;Наименование магазина<br/>";
    print "<input type=text name=modoption value='$_[0]->{'OGRN'}'>&nbsp;ОГРН<br/>";
    print "<input type=text size=35 name=modoption value='$_[0]->{'ADDRESS'}'>&nbsp;Адрес продавца<br/>";
    print "<input type=text size=35 name=modoption value='$_[0]->{'FNAME'}'>&nbsp;Полное фирменное наименование<br/>";
    print "<input type=text name=modoption value='$_[0]->{'EMAIL'}'>&nbsp;Эл. почта<br/><hr width=100%>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'CONSPROP'}] value='$_[0]->{'CONSPROP'}' title='информация об основных потребительских свойствах товара'>&nbsp;Основные свойства товара<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'PRICEINFO'}] value='$_[0]->{'PRICEINFO'}' title='О цене и об условиях приобретения товара'>&nbsp;Цена и условия приобретения<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'DELIVERYINFO'}] value='$_[0]->{'DELIVERYINFO'}' title='Информация о его доставке'>&nbsp;Информация о доставке<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'GUARANTEE'}] value='$_[0]->{'GUARANTEE'}' title='Сроке службы, сроке годности и гарантийном сроке'>&nbsp;Гарантия, срок службы<br/>";
    print "<input type=text size=4 name=modoption value='$_[0]->{'ACCEPT'}' title='Срок, в течение которого действует предложение о заключении договора.'>&nbsp;Срок акцепта<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'CASHBACK'}] value='$_[0]->{'CASHBACK'}' title='Информация о порядке и сроках возврата товара надлежащего качества'>&nbsp;Срок и порядок возврата (надл. кач.)<br/>";
    print "<input type=text size=4 name=modoption value='$_[0]->{'GOODBACKDAYS'}' title='Срок возврата тов. надл.кач.'>&nbsp;Срок возврата товара<br/>";
    print p("Дата регистрации (изменения): $_[0]->{'SYSDATE'}");
    print '</td><td>';
    print p('Информация о доставке');
    print "<input type=checkbox name=modoption $checked[$_[0]->{'DT_MAIL'}] value='$_[0]->{'DT_MAIL'}'>&nbsp;Почта РФ<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'DT_CC'}] value='$_[0]->{'DT_CC'}'>&nbsp;Курьерские компании<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'DT_TC'}] value='$_[0]->{'DT_TC'}'>&nbsp;Транспортные компании<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'DT_CR'}] value='$_[0]->{'DT_CR'}'>&nbsp;Курьер<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'DT_PP'}] value='$_[0]->{'DT_PP'}'>&nbsp;Самовывоз<br/>";
    print '</td></tr><tr><td>';
    print p('Информация об оплате');
    print "<input type=checkbox name=modoption $checked[$_[0]->{'PT_BP'}] value='$_[0]->{'PT_BP'}'>&nbsp;Банковский платеж<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'PT_EM'}] value='$_[0]->{'PT_EM'}'>&nbsp;Электронные деньги<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'PT_CH'}] value='$_[0]->{'PT_CH'}'>&nbsp;Платеж наличными<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'PT_PM'}] value='$_[0]->{'PT_PM'}'>&nbsp;Наложенный платеж<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'PT_BC'}] value='$_[0]->{'PT_BC'}'>&nbsp;Банковские карты<br/>";
    print "<input type=checkbox name=modoption $checked[$_[0]->{'PT_TP'}] value='$_[0]->{'PT_TP'}'>&nbsp;Терминалы оплаты<br/>";
    print '</td></tr><tr><td colspan=2 align=center>';
    print submit(-value=>'Save changes');
    print '</td></tr></table>';
    print hidden(-name=>'module',
                 -value=>'Registry');
    print end_form;
}

#Процедура сохранения данных регистрационной формы
sub SaveCompanyForm()
{
    
}

#Процедура проверка существования URL
sub CheckURL()
{
    my @status=('False','Ok');
    $SQL="SET NAMES UTF8";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    $SQL="SELECT `ID`, `ORGANIZATION`, `URL`, `OGRN`, `CONSPROP`, `ADDRESS`, `FNAME`, `PRICEINFO`, `DELIVERYINFO`, `GUARANTEE`, `ACCEPT`, `CASHBACK`, `SYSDATE`,
    `EMAIL`, `DT_MAIL`, `DT_CC`, `DT_TC`, `DT_CR`, `DT_PP`, `PT_BP`, `PT_EM`, `PT_CH`, `PT_PM`, `PT_BC`, `PT_TP`, `GOODBACKDAYS` FROM COMPANYREF WHERE URL='$_[0]'";
    $sth=$dbh->prepare($SQL);
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