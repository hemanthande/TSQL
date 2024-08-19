/*Query To Return Server DB's Sizes */
SELECT ServerName = @@SERVERNAME
	,ServiceName =@@SERVICENAME
	,CurrentDatabaseName = DB_NAME()
	,@@VERSION 

GO

SELECT DBNAME = DB_NAME(database_id)
	,SizeMb = Cast(SUM(size * 8 / 1024.00) AS NUMERIC(32, 2))
	,backupSQK = 'BACKUP DATABASE ' + DB_NAME(database_id) +' TO DISK = ''C:\SQLServer_Backups\'+DB_NAME(database_id) + '.bak''  WITH NOFORMAT, NAME = ''' + @@SERVERNAME +' as of '+ CONVERT(NVARCHAR, GETDATE(), 101)+ '''; ' 
	--,current_file_location = physical_name 
FROM master.sys.master_files T
WHERE database_id NOT IN (DB_ID('master'), DB_ID('model'), DB_ID('msdb'), DB_ID('tempdb'))
GROUP BY DB_NAME(database_id)--, physical_name 
--Order by Size desc, DBNAME
--ORDER BY SizeMb DESC
Order by DBNAME

