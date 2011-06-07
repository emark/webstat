package Syspkg;
use strict;
use constant VERSION=>1.1;
BEGIN;

sub DBconf()
{
    open (DBCONF,"< db.conf") || die "Error open dbconfig file";
    my @dbconf=<DBCONF>;
    close DBCONF;
    chomp @dbconf;
    return @dbconf;
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
