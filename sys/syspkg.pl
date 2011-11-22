package Syspkg;
use strict;
use constant VERSION=>1.1;
BEGIN;

#Colorizing table
sub Rowcolor(){
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

#Reading data from static files;
sub Static(){
    my $statdir='../static';
    my @data='';
    open (STATIC,"< $statdir/$_[1]") || die "Can't open static file: @_";
    @data=<STATIC>;
    close STATIC;
    chomp @data;
    return @data;
}
return 1;
END;
