SELECT DBNAME = DB_NAME(database_id), 
       Size = Cast(SUM(size * 8/ 1024.00) as NUMERIC(32,2))
FROM master.sys.master_files
GROUP BY DB_NAME(database_id)
--Order by Size desc, DBNAME
Order by Size DESC