#!/usr/bin/perl -w
use strict;
use DBI;
require 'pkg/poststat.pl';

my $dbh=undef;#Database description
my $sth=undef;
my $ref=undef;

#Connection with database
$dbh=DBI->connect("DBI:mysql:database=COMMON;host=localhost","root","admin");
$dbh->trace();
$sth=$dbh->prepare(PostStat::TopList());
$sth->execute();
while ($ref=$sth->fetchrow_hashref)
{
    print "$ref->{'URL'}\t$ref->{'SUM'}\t$ref->{'COUNT'}\n";
}
