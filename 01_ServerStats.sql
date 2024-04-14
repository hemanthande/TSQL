/*Query To Return Server DB's Sizes */
SELECT ServerName = @@SERVERNAME
	,ServiceName =@@SERVICENAME
	,CurrentDatabaseName = DB_NAME()
	,@@VERSION 

GO

SELECT DBNAME = DB_NAME(database_id)
	,SizeMb = Cast(SUM(size * 8 / 1024.00) AS NUMERIC(32, 2))
FROM master.sys.master_files
GROUP BY DB_NAME(database_id)
--Order by Size desc, DBNAME
ORDER BY SizeMb DESC
