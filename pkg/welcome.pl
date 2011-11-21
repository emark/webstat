#Testing module
package Welcome;
use strict;

#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='Welcome';
my $modoption='';

BEGIN;

sub Init()
{
    &main::HTMLDisplay;
    my @modoption=('','');
    if($_[2])
    {
        @modoption=split (/:/,$_[2]);
        $modoption=$_[2];#Define global var
    }  
    #Connection with database
    $dbh=DBI->connect(&Syspkg::Static($main::dbconf));
    $dbh->trace();
    &CommonStatistic();
    &Disconnect;
}

sub CommonStatistic()
{
    print 'Welcome to WebStatistics';
}

sub Disconnect()
{
    $ref=undef;
    $sth=undef;
    $dbh->disconnect;
    $dbh=undef;
    print '<P class=sysmsg>Connection close</P>';
    &main::HTMLfinish;
}

return $module;
END;