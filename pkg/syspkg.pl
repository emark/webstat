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
    my @bgcolor=('#005566','#ffffff');
}

return 1;
END;
