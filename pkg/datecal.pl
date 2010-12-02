#Пакет для работы с датами/временным интервалом
package Datecal;
use strict;
use DateTime;
use constant VERSION=>1.01;

my $date_in=undef;
my $date_out=undef;

BEGIN;

#Процедура валидации и проверки временного интервала
#USAGE: (date_in,date_out)
sub GetDates()
{
    if(!$_[0])
    {
        $date_in=DateTime->now()->ymd;
    }
    else
    {
        $date_in=$_[0];
    }
    if(!$_[1])
    {
        $date_out=DateTime->now();
        $date_out->add(days=>1);
        $date_out=$date_out->ymd;
    }
    else
    {
        $date_out=$_[1];
    }
    return 1;
}

sub DateIn()
{
    return $date_in;
}

sub DateOut()
{
    return $date_out;
}

sub Period()
{
    return $date_in,$date_out;
}

#Процедура вывода предустановленных параметров
# Today, Yesterday, Week, Month
#USAGE: (module)
#module - selected module
sub PresetDates()
{
    my $module=$_[0];
    my $today=DateTime->now();
    my $yesterday=$today->clone()->add(days=>-1)->ymd;
    my $tommorow=$today->clone()->add(days=>1)->ymd;
    my $week=$today->clone()->subtract(days=>7)->ymd;
    my $month=$today->clone()->set_day(1)->ymd;
    $today=$today->ymd;
    my ($preset,$date_in,$date_out);
    my @PresetDates=("Today;$today;$tommorow",
                     "Yesterday;$yesterday;$today",
                     "For 7 days;$week;$today",
                     "Month;$month;$today"
                     );
    #print $today,$yesterday,$tommorow,$week;
    foreach my $key(@PresetDates)
    {
        ($preset,$date_in,$date_out)=split(/;/,$key);
        print "<a href=\"?date_in=$date_in&date_out=$date_out&module=$module\">$preset</a>&nbsp;\n";
    }
    return 1;
}

return 1;
END;