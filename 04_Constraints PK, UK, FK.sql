--SQL Server Data Dictionary Query Toolbox
--List all table constraints (PK, UK, FK, Check & Default) in SQL Server database

use AdventureWorks2022
SELECT table_view
	,object_type
	,constraint_type
	,constraint_name
	,details
FROM (
	SELECT schema_name(t.schema_id) + '.' + t.[name] AS table_view
		,CASE 
			WHEN t.[type] = 'U' THEN 'Table'
			WHEN t.[type] = 'V' THEN 'View'
			END AS [object_type]
		,CASE 
			WHEN c.[type] = 'PK'    THEN 'Primary key'
			WHEN c.[type] = 'UQ'    THEN 'Unique constraint'
			WHEN i.[type] = 1       THEN 'Unique clustered index'
			WHEN i.type = 2         THEN 'Unique index'
			END AS constraint_type
		,isnull(c.[name], i.[name]) AS constraint_name
		,substring(column_names, 1, len(column_names) - 1) AS [details]
	FROM sys.objects t
	LEFT OUTER JOIN sys.indexes i ON t.object_id = i.object_id
	LEFT OUTER JOIN sys.key_constraints c ON i.object_id = c.parent_object_id 	AND i.index_id = c.unique_index_id
	CROSS APPLY (
		SELECT col.[name] + ', '
		FROM sys.index_columns ic
		INNER JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
		WHERE ic.object_id = t.object_id AND ic.index_id = i.index_id
		ORDER BY col.column_id
		FOR XML path('')
		) D(column_names)
    WHERE is_unique = 1 
		AND t.is_ms_shipped <> 1
	
	UNION ALL
	
	SELECT schema_name(fk_tab.schema_id) + '.' + fk_tab.name AS foreign_table
		,'Table'
		,'Foreign key'
		,fk.name AS fk_constraint_name
		,schema_name(pk_tab.schema_id) + '.' + pk_tab.name
	FROM sys.foreign_keys fk
	INNER JOIN sys.tables fk_tab ON fk_tab.object_id = fk.parent_object_id
	INNER JOIN sys.tables pk_tab ON pk_tab.object_id = fk.referenced_object_id
	INNER JOIN sys.foreign_key_columns fk_cols ON fk_cols.constraint_object_id = fk.object_id
	
	UNION ALL
	
	SELECT schema_name(t.schema_id) + '.' + t.[name]
		,'Table'
		,'Check constraint'
		,con.[name] AS constraint_name
		,con.[definition]
	FROM sys.check_constraints con
	LEFT OUTER JOIN sys.objects t ON con.parent_object_id = t.object_id
	LEFT OUTER JOIN sys.all_columns col ON con.parent_column_id = col.column_id
		AND con.parent_object_id = col.object_id
	
	UNION ALL
	
	SELECT schema_name(t.schema_id) + '.' + t.[name]
		,'Table'
		,'Default constraint'
		,con.[name]
		,col.[name] + ' = ' + con.[definition]
	FROM sys.default_constraints con
	LEFT OUTER JOIN sys.objects t ON con.parent_object_id = t.object_id
	LEFT OUTER JOIN sys.all_columns col ON con.parent_column_id = col.column_id
		AND con.parent_object_id = col.object_id
	) a
WHERE 1=1
--and a.table_view = 'HumanResources.EmployeeDepartmentHistory'
--and a.table_view = 'HumanResources.Employee'
ORDER BY table_view
	,constraint_type
	,constraint_name
