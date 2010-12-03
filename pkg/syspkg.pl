package Syspkg;
use strict;
use constant VERSION=>1.0;
BEGIN;

sub DBconf()
{
    return "DBI:mysql:database=COMMON;host=localhost","root","admin";
}

#Подсветка таблицы "зеброй" в строках
sub Rowcolor()
{
    my $color=0;
    if($_[0] & 1)
    {
        $color='#FFFFFF'
    }
    else
    {
        $color='#F0F0F0'
    }
    return $color;
}

return 1;
END;
