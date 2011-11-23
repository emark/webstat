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
    my $path='static/';
    my $file=$path.$_[0];
    my @data='';
    open (STATIC,"< $file") || die "Can't open static file: $file";
    @data=<STATIC>;
    close STATIC;
    chomp @data;
    return @data;
}
return 1;
END;
