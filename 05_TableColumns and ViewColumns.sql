/*Tables and View details */
/*Lists all Tables and its Columns in a Database*/
SELECT TableName
	,ColumnName
	,Corder
	,DataType
	,max_length
	,precision
	,scale
	,SqlGrpByCol
FROM (
	SELECT DB_NAME() + '.' + Sc.name + '.' + T.name AS TableName
		,C.name AS ColumnName
		,Corder = C.column_id
		,DataType = typ.name
		,C.max_length
		,C.precision
		,C.scale
		,'-- Select ' + C.name + ', Ct = Count(1) from ' + Sc.name + '.' + T.name + ' GROUP BY ' + C.name + ' ORDER BY Ct Desc' AS SqlGrpByCol
	FROM sys.tables AS T
	INNER JOIN sys.schemas AS Sc ON T.schema_id = Sc.schema_id
	INNER JOIN sys.columns AS C ON T.object_id = C.object_id
	LEFT OUTER JOIN sys.types AS typ ON C.user_type_id = typ.user_type_id
	WHERE (1 = 1)
	) AS C_L
WHERE 1 = 1
--AND C_L.TableName = 'AdventureWorks2022.HumanResources.Department'
ORDER BY TableName
	,Corder

/*Lists all Views and its Columns in a Database*/
SELECT ViewName
	,ColumnName
	,Corder
	,DataType
	,max_length
	,precision
	,scale
	,SqlGrpByCol
FROM (
	SELECT DB_NAME() + '.' + Sc.name + '.' + T.name AS ViewName
		,C.name AS ColumnName
		,Corder = C.column_id
		,DataType = typ.name
		,C.max_length
		,C.precision
		,C.scale
		,'-- Select ' + C.name + ', Ct = Count(1) from ' + Sc.name + '.' + T.name + ' GROUP BY ' + C.name + ' ORDER BY Ct Desc' AS SqlGrpByCol
	FROM sys.VIEWS AS T
	INNER JOIN sys.schemas AS Sc ON T.schema_id = Sc.schema_id
	INNER JOIN sys.columns AS C ON T.object_id = C.object_id
	LEFT OUTER JOIN sys.types AS typ ON C.user_type_id = typ.user_type_id
	WHERE (1 = 1)
	) AS C_L
WHERE 1 = 1
ORDER BY ViewName
	,Corder
