#links regisrty module
package Links;
use strict;
#use CGI qw/:standard/;
use constant VERSION=>0.1;

#Database description
my $dbh=undef;
my $sth=undef;
my $ref=undef;
my $SQL='';
my $module='Links';

BEGIN;

sub Init()
{
    &main::HTMLDisplay;
    my @modoption=@_;#Get form data (date_from,date_till,modoption)
    my %pages=('createlink'=>'Create link',
               'managelink'=>'Manage links',
               'deletelink'=>'Delete links'
               );
    print "<P align=center>";
    foreach my $key(keys %pages){
        print "<a href=\"?date_in=$_[0]&date_out=$_[1]&module=$module&modoption=$key\">$pages{$key}</a>&nbsp";
    }
    print "<br><i>$pages{$modoption[2]}</i></P>";
    #Connection with database
    $dbh=DBI->connect(&Syspkg::Static($::dbconf));
    $::dbconf=undef;
    $dbh->trace();
    if($modoption[2] eq 'createlink'){
        &CreateLink(@modoption);
    }elsif($modoption[2] eq 'managelink'){
        &ManageLinks(@modoption);
    }elsif($modoption[2] eq 'deletelink'){
        &DeleteLink(@modoption);
    }
    &Disconnect;
};

#Manage existing links
#ENV(date_in,date_out,page,catid,linktype,linkid)
sub ManageLinks(){
    my $catid=$_[3];
    my @linktype=('IS NULL','IS NOT NULL');
    $SQL="SET NAMES UTF8";
    $sth=$dbh->prepare($SQL);
    $sth->execute();
    print '<form action="?" method=get>';
    print "<input type=hidden name=date_in value=$_[0]>";
    print "<input type=hidden name=date_out value=$_[1]>";
    print "<input type=hidden name=module value=$module>";
    print "<input type=hidden name=modoption value=managelink>";
    print '<P>Select category <select name=modoption><option value=0>All category';
    $SQL="SELECT CATEGORY.id,CATEGORY.name FROM CATEGORY";
    $sth=$dbh->prepare($SQL);
    $sth->execute;
    while($ref=$sth->fetchrow_hashref){
        print "<option value=$ref->{'id'} ";
        print 'selected' if($catid==$ref->{'id'});
        print " >$ref->{'name'}";
    }
    print '</select>, ';
    print 'select link type <select name=modoption><option value="0">Company<option value="1">Links</select>&nbsp;';
    print "<input type=submit value='Show me links'></form></P>";
    #Generate links table
    $SQL="SELECT CATEGORY.name AS category,LINKS.id as linkid,LINKS.companyid,LINKS.content,LINKS.createdate,COMPANYREF.ORGANIZATION AS orgname,COMPANYREF.URL AS url FROM CATEGORY RIGHT JOIN LINKS ON CATEGORY.id=LINKS.catid LEFT JOIN COMPANYREF ON
    LINKS.companyid=COMPANYREF.ID WHERE LINKS.content $linktype[$_[4]] ";
    $SQL=$SQL. "AND CATEGORY.id=$catid" if ($catid);
    $sth=$dbh->prepare($SQL);#print $SQL;
    $sth->execute;
    print '<table border=1 cellpadding=3><tr><td>category</td><td>company</td><td>url</td><td>content</td><td>create</td><td>delete / edit</td></tr>';
    while($ref=$sth->fetchrow_hashref){
        print "<tr><td>$ref->{'category'}</td><td><a href=\"?module=Registry&modoption=check&modoption=$ref->{'url'}\">$ref->{'orgname'}</a></td><td><a href=\"http://$ref->{'url'}\" target=_blank>$ref->{'url'}</a></td><td><a href=\"http://$ref->{'content'}\" target=_blank>$ref->{'content'}</a></td><td>$ref->{'createdate'}</td><td><a href=\"?date_in=$_[0]&date_out=$_[1]&module=$module&modoption=deletelink&modoption=$ref->{'linkid'}\">delete</a></td></tr>";
    }
    print '</table>';
};

#Drop link by id
#ENV(date_in,date_out,page,linkid)
sub DeleteLink(){
    my $linkid=$_[3];
    print '<P align=center>Select link on "Manage links" page</P>';
    if($linkid){
        $sth=$dbh->prepare("DELETE FROM LINKS WHERE LINKS.id=$linkid");
        $sth->execute;
        if($sth->err){
            print 'error while removed link';
        }else{
            print 'Links was removed successfully';
        }
    }
}

#Createing new link
#ENV(date_in,date_out,page,catid,content)
sub CreateLink(){
    if(!$_[4]){#Starting app
        print '<form action="?" method=post target=_self>';
        print "<input type=hidden name=module value=$module>";
        print "<input type=hidden name=modoption value=createlink>";
        print '<P>Select category <select name=modoption>';
        $SQL="SELECT CATEGORY.id,CATEGORY.name FROM CATEGORY";
        $sth=$dbh->prepare($SQL);
        $sth->execute;
        while($ref=$sth->fetchrow_hashref){
            print "<option value=$ref->{'id'}>$ref->{'name'}";
        }
        print '</select>';
        print '<input type=textfield name="modoption" size=50>';
        print '<input type=submit value="Create new link">';
        print '</form></P>';
    }else{#Generate link
        my $catid=$_[3];
        my $content=$_[4];
        my %link=();
        $SQL="SELECT l.id,l.content FROM LINKS l WHERE l.content=\"$content\" AND l.catid=$catid";
        $sth=$dbh->prepare($SQL);
        $sth->execute;
        if($sth->rows){
            print 'Existing link';
            while($ref=$sth->fetchrow_hashref){
                $link{$ref->{'id'}}=$ref->{'content'};
            }
        }else{
            print 'Generate new link';
            $dbh->do("INSERT INTO LINKS(id,catid,companyid,content,createdate) VALUES (NULL,$catid,1,\"$content\",NOW())");
            $link{$dbh->last_insert_id('','','LINKS','id')}=$content;
        }
        foreach my $key(keys%link){
            print "<textarea name='link' cols=50 rows=10><a href=\"http://go.web2buy.ru/l/$key/link.html\" rel=\"nofollow\" target=_blank>$link{$key}</a></textarea>";
        }
    }
};

sub Disconnect()
{
    $ref=undef;
    $sth=undef;
    $dbh->disconnect;
    $dbh=undef;
    print '<P class=sysmsg>Connection close</P>';
    &main::HTMLfinish;
};

return $module;
END;