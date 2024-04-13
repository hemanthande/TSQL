/*Query To Return Server DB's Sizes */
Select @@SERVERNAME, @@SERVICENAME, DB_NAME(), @@VERSION GO

SELECT DBNAME = DB_NAME(database_id),
       SizeMb = Cast(SUM(size * 8/ 1024.00) as NUMERIC(32,2))
FROM master.sys.master_files
GROUP BY DB_NAME(database_id)
--Order by Size desc, DBNAME
Order by SizeMb DESC