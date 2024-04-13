/*Summary of All Objects except Triggers in this database*/
SELECT SO.ObjType
	,Ct = Count(1)
	,ParentCt = Sum(SO.Parent)
	,ChildCt = Sum(SO.Child)
	,allocated_mb = Sum(SO.allocated_mb)
	,used_mb = Sum(SO.used_mb)
FROM (
	SELECT Obj.object_id
		,ObjName = SCHEMA_NAME(Obj.schema_id) + '.' + Obj.name
		,Parent = CASE  WHEN Obj.parent_object_id = 0 THEN 1 ELSE 0 END
		,Child = CASE  WHEN Obj.parent_object_id = 0 THEN 0 ELSE 1 END
		,ObjTypeId = Obj.[type]
		,ObjType = type_desc
		,create_date = Cast(obj.create_date AS DATE)
		,modify_date = Cast(obj.modify_date AS DATE)
		,principal_id = ISNULL(Cast(Obj.principal_id AS CHAR(2)), '')
		,Tsize.allocated_mb
		,Tsize.used_mb
	FROM sys.objects AS Obj
	/* Query to Table Sizes */
	LEFT JOIN (
		SELECT p.object_id
			,allocated_mb = Cast((SUM(u.total_pages) * 8) / 1024.0 AS NUMERIC(36, 2))
			,used_mb = Cast((SUM(u.used_pages) * 8) / 1024.0 AS NUMERIC(36, 2))
		FROM sys.allocation_units AS u
		JOIN sys.partitions AS p ON u.container_id = p.hobt_id
		GROUP BY p.object_id
		) AS Tsize ON Obj.object_id = Tsize.object_id
	) AS SO
GROUP BY SO.ObjType
ORDER BY 1

SELECT Obj.object_id
	,ObjName = SCHEMA_NAME(Obj.schema_id) + '.' + Obj.name
	,obj.parent_object_id
	,P_Obj.parent_object
	,ObjTypeId = Obj.[type]
	,ObjType = type_desc
	,create_date = Cast(obj.create_date AS DATE)
	,modify_date = Cast(obj.modify_date AS DATE)
	,principal_id = ISNULL(Cast(Obj.principal_id AS CHAR(2)), '')
	,Tsize.allocated_mb
	,Tsize.used_mb
	,Tsize.R_Count
FROM sys.objects AS Obj
JOIN sys.schemas Sc ON Obj.schema_id = Sc.schema_id
LEFT JOIN (
	SELECT parent_object_id = Obj.object_id
		,parent_object = SCHEMA_NAME(Obj.schema_id) + '.' + Obj.name
	FROM sys.objects AS Obj
	) AS P_Obj ON Obj.parent_object_id = P_Obj.parent_object_id
LEFT JOIN (
	SELECT O.object_id
		,allocated_mb = Cast((SUM(u.total_pages) * 8) / 1024.0 AS NUMERIC(36, 2))
		,used_mb = Cast((SUM(u.used_pages) * 8) / 1024.0 AS NUMERIC(36, 2))
		,R_Count = max(p.rows)
	FROM sys.allocation_units AS u
	JOIN sys.partitions AS p ON u.container_id = p.hobt_id
	JOIN sys.objects AS O ON p.object_id = O.object_id
	GROUP BY O.object_id
	) AS Tsize ON Obj.object_id = Tsize.object_id
WHERE 1 = 1
--AND Obj.object_id = 363148339 --xml_index_nodes_2101582525_256001
ORDER BY ObjType,ObjName,object_id