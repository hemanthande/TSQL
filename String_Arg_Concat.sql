
Select 
PC.ProductCategoryID,
PC.Name,
PSC.ProductSubcategoryID,
PSC.NAME
from AdventureWorks2022.Production.ProductCategory PC
LEFT JOIN AdventureWorks2022.Production.ProductSubcategory PSC ON PC.ProductCategoryID = PSC.ProductCategoryID


Select 
PC.ProductCategoryID,
ProductName = PC.Name,
ProductSubcategoryList = STRING_AGG(PSC.NAME, ', ') WITHIN GROUP(order By PSC.ProductSubcategoryID)  
from AdventureWorks2022.Production.ProductCategory PC
LEFT JOIN AdventureWorks2022.Production.ProductSubcategory PSC ON PC.ProductCategoryID = PSC.ProductCategoryID
GROUP BY PC.ProductCategoryID , PC.Name

Select 
PC.ProductCategoryID,
ProductName = PC.Name,
ProductSubcategoryList = STRING_AGG(PSC.NAME, ' | ') WITHIN GROUP(order By PSC.Name Desc)  
from Production.ProductCategory PC
LEFT JOIN Production.ProductSubcategory PSC ON PC.ProductCategoryID = PSC.ProductCategoryID
GROUP BY PC.ProductCategoryID , PC.Name