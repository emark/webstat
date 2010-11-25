#Модуль статистики голосований постов
package PostStat;
BEGIN;
sub TopList()
{
    my $SQL="SELECT URL,SUM(ANSWER) AS SUM,COUNT(ANSWER) AS COUNT FROM POSTSTAT GROUP BY URL ORDER BY SUM DESC";
    #print $SQL;
    return $SQL;
}
return 1;
END;