package Syspkg;
use strict;
use constant VERSION=>1.1;
BEGIN;

sub DBconf()
{
    my @production=('DBI:mysql:database=COMMON;host=localhost','service','RrFTkLX2');
    my @develop=('DBI:mysql:database=locumtes_web2b58;host=localhost','root','admin');
    return @develop;
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
