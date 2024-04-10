USE AdventureWorks2022

SELECT TStats.TableName
    ,TStats.object_id
    ,TStats.R_Count
    ,TStats.C_Ct
    ,Tsize.allocated_mb
	,Tsize.used_mb
    ,TStats.SqlTop100
FROM (
	SELECT TableName = DB_NAME() + '.' + Sc.name + '.' + T.name
		,T.object_id
		,R_Count = SUM(PART.rows)
		,CInfo.C_Ct
		,SqlTop100 = '-- Select Top 100 * from ' + DB_NAME() + '.' + Sc.name + '.' + T.name
	FROM sys.tables T
	JOIN sys.schemas Sc ON T.schema_id = Sc.schema_id
	INNER JOIN sys.partitions PART ON T.object_id = PART.object_id
	INNER JOIN sys.indexes IDX ON PART.object_id = IDX.object_id
		AND PART.index_id = IDX.index_id
		AND IDX.index_id < 2 --Only get either Heap or Clusterd index and (0 or 1 only 1 is possible.)
		/* Query to Get Column Count */
	JOIN (
		SELECT T.object_id
			,C_Ct = COUNT(DISTINCT C.column_id)
		FROM sys.tables T
		INNER JOIN Sys.columns C ON T.object_id = c.object_id
		GROUP BY t.object_id
		) AS CInfo ON T.object_id = CInfo.object_id
	GROUP BY Sc.name
		,T.name
		,CInfo.C_Ct
		,T.object_id
	) AS TStats
/* Query to Table Sizes */
JOIN (
	SELECT tab.object_id
		,used_mb = cast(sum(spc.used_pages * 8) / 1024.00 AS NUMERIC(36, 2))
		,allocated_mb = cast(sum(spc.total_pages * 8) / 1024.00 AS NUMERIC(36, 2))
	FROM sys.tables tab
	INNER JOIN sys.indexes ind ON tab.object_id = ind.object_id
	INNER JOIN sys.partitions part ON ind.object_id = part.object_id
		AND ind.index_id = part.index_id
	INNER JOIN sys.allocation_units spc ON part.partition_id = spc.container_id
	GROUP BY tab.object_id
	) AS Tsize ON TStats.object_id = Tsize.object_id
WHERE 1=1
ORDER BY TStats.TableName