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
    if($_[0])
    {
        @modoption=split (/:/,$_[0]);
        $modoption=$_[0];#Define global var
    }  
    #Connection with database
    $dbh=DBI->connect(&Syspkg::Static($::dbconf));
    $::dbconf=undef;
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