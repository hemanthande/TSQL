SELECT 
	PrimaryObjName = COALESCE((SCHEMA_NAME(Obj.schema_id) + '.'+ [Obj].name),(SCHEMA_NAME(ParObj.schema_id) + '.'+ [ParObj].name)),
	[DBObjs].[name],
	[DBObjs].[object_id],
	[DBObjs].[type_desc],
	[DBObjs].[Parent],
	[DBObjs].[Child]	
FROM (
	/*Indexes */
	SELECT i.name
		,i.object_id
		,type_desc = 'INDEX_'+i.type_desc
		,Parent = STRING_AGG(SCHEMA_NAME(obj.schema_id) + '.' + c.name, ', ') WITHIN  GROUP ( ORDER BY ic.key_ordinal )
		,Child = NULL
	FROM sys.indexes AS i
	JOIN sys.objects AS obj ON i.object_id = obj.object_id
	JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
	JOIN sys.columns c ON ic.column_id = c.column_id AND ic.object_id = c.object_id
	WHERE is_hypothetical = 0
		AND i.index_id <> 0
		AND obj.is_ms_shipped <> 1
	GROUP BY i.name
		,i.object_id
		,i.type_desc
	
	UNION ALL
	
	/*PRIMARY_KEY_CONSTRAINT*/
	SELECT O.name
		,O.object_id
		,O.type_desc
		,Parent = STRING_AGG(SCHEMA_NAME(iObj.schema_id) + '.' + OBJECT_NAME(iObj.object_id) + '.' + c.name, ', ') WITHIN GROUP ( ORDER BY ic.key_ordinal )
		,Child = NULL
	FROM sys.objects O
	JOIN sys.indexes i ON O.parent_object_id = i.object_id
	JOIN sys.objects iObj ON i.object_id = iObj.object_id
	JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
	JOIN sys.columns c ON ic.column_id = c.column_id AND ic.object_id = c.object_id
	WHERE O.type_desc = 'PRIMARY_KEY_CONSTRAINT'
		AND O.is_ms_shipped <> 1
		AND i.is_primary_key = 1
	GROUP BY O.name
		,O.object_id
		,O.type_desc
	
	UNION ALL
	
	/*FOREIGN_KEY_CONSTRAINT*/
	SELECT fk.name AS ForeignKeyName
		,fk.object_id
		,fk.type_desc
		,Parent = STRING_AGG(SCHEMA_NAME(t_parent.schema_id) + '.' + t_parent.name + '.' + c_parent.name, ', ') WITHIN GROUP ( ORDER BY fkc.constraint_column_id )
		,Child = STRING_AGG(SCHEMA_NAME(t_child.schema_id) + '.' + t_child.name + '.' + c_child.name, ', ') WITHIN GROUP ( ORDER BY fkc.constraint_column_id )
	FROM sys.foreign_keys fk
	INNER JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
	INNER JOIN sys.tables t_parent ON t_parent.object_id = fk.parent_object_id
	INNER JOIN sys.columns c_parent ON fkc.parent_column_id = c_parent.column_id AND c_parent.object_id = t_parent.object_id
	INNER JOIN sys.tables t_child ON t_child.object_id = fk.referenced_object_id
	INNER JOIN sys.columns c_child ON c_child.object_id = t_child.object_id AND fkc.referenced_column_id = c_child.column_id
	GROUP BY fk.name
		,fk.object_id
		,fk.type_desc
	
	UNION ALL
	
	/*DEFAULT_CONSTRAINT*/
	SELECT DC.name
		,DC.object_id
		,DC.type_desc
		,Parent = SCHEMA_NAME(schema_id) + '.' + OBJECT_NAME(parent_object_id) + '.' + C.name + ' = ' + DEFINITION
		,Child = NULL
	FROM sys.default_constraints DC
	JOIN sys.columns C ON DC.parent_object_id = C.object_id AND DC.parent_column_id = C.column_id
	WHERE is_ms_shipped = 0
	
	UNION ALL
	
	/*CHECK_CONSTRAINT*/
	SELECT CC.name
		,CC.object_id
		,CC.type_desc
		,Parent = SCHEMA_NAME(schema_id) + '.' + OBJECT_NAME(parent_object_id) + '.' + C.name + ' = ' + DEFINITION
		,Child = NULL
	FROM sys.check_constraints CC
	JOIN sys.columns C ON CC.parent_object_id = C.object_id AND CC.parent_column_id = C.column_id
	WHERE is_ms_shipped = 0
	
	UNION ALL
	
	/*SQL_TRIGGER*/
	SELECT t.name
		,t.object_id
		,t.[type_desc]
		,Parent = SCHEMA_NAME(O.schema_id) + '.' + OBJECT_NAME(O.object_id)
		,Child = NULL
	FROM sys.triggers t
	JOIN sys.objects O ON t.parent_id = O.object_id
	) AS DBObjs
LEFT JOIN sys.objects Obj on DBObjs.object_id = obj.object_id and DBObjs.type_desc like 'INDEX_%'
LEFT JOIN sys.objects PObj on DBObjs.object_id = PObj.object_id  and DBObjs.type_desc NOT like 'INDEX_%'
LEFT JOIN sys.objects ParObj on ParObj.object_id = PObj.parent_object_id  and ParObj.parent_object_id = 0 

ORDER BY PrimaryObjName,type_desc,name