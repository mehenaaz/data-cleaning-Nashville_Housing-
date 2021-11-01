# Clean Data Using SQL queries On "Nashville Housing Dataset"

This readme is to give the description of  the dataset and to  show the comparisons between sql queries of two tools: MySQL Workbench 8.0 CE & Microsoft SQL Server Management Studio 18.

Dataset Description:

This dataset contains Information of all about  customer  and  details of a house renting.

Columns:

UniqueID, ParcelID,Landuse,Property Address,SaleDate,SalePrice,LegalRefrences,SoldAsVacant,OwnerName,Owner Address,Acreage,TAxDistrict,LandValue,BuildingValue.TotalValue,YearBuilt,Bedrooms,Fullbath,Halfbath.

Aim:

- Standardize Date Format
- Populate Property Address Data
- Breaking out Address into Individual Columns (Address, City, State)
- Change Y and N to Yes and No in "Sold as Vacant" field
- Delete Duplicates
- Delete Unused Columns



Tools:

MySQL Workbench 8.0 CE

Microsoft SQL Server Management Studio 18



Comparison Between Queries of MySQL Workbench & Microsoft SQL Server:

​					Mysql                                                                                                                    SQL server

* ```select SaleDate,convert(SaleDate,Date)```                                       ``` select SaleDate,convert(Date,SaleDate) ```





Update a (sql server)

Set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress) 
from portfolio_1.dbo.NashvilleHousing a 
Join portfolio_1.dbo.NashvilleHousing b 
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] 
where a.PropertyAddress is null;







* ```Update NVH a -- labelling as "a"    (mysql)
  Join NVH b -- labelling as "b"
  on a.ParcelID=b.ParcelID
  and a.UniqueID <>b.UniqueID 
  Set a.PropertyAddress=IFNULL(a.PropertyAddress,b.PropertyAddress) 
  where a.PropertyAddress is null;```
  ```
  
  







* sql server= ```SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address```

* msql=  ```SUBSTRING(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) as Address```

  





Sql server=``` LEN(PropertyAddress))```

mqsl= ```CHAR_LENGTH(RTRIM(PropertyAddress)```



sql=```PARSENAME (REPLACE(OwnerAddress,',','.'),3)```

msql=```SUBSTRING_INDEX(OwnerAddress,',',1)```











check for duplicates:

sql= 

​     WITH RowNumCTE AS(
Select *,
​	ROW_NUMBER() OVER (                   --ROW_NUMBER() function to assign a sequential integer to each row of a result set.
​	PARTITION BY ParcelID,                -- partition on things should be unique to each row 
​				 PropertyAddress,
​				 SalePrice,
​				 SaleDate,
​				 LegalReference
​				 ORDER BY
​					UniqueID
​					) row_num

From NashvilleHousing)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress









msql=

SELECT UniqueID, 
    ROW_NUMBER() OVER ( 
		PARTITION BY  ParcelID,                -- partition on things should be unique to each row 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	) AS row_num 
FROM NVH;







remove duplicates:



sql=

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (                   --add a new column "row number"
	PARTITION BY ParcelID,                -- partition on things should be unique to each row 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing)

Delete
From RowNumCTE
Where row_num > 1



msql=

DELETE FROM NVH  
WHERE 
	UniqueID IN (
	SELECT 
		UniqueID 
	FROM (
		SELECT 
			UniqueID,
			ROW_NUMBER() OVER (
				PARTITION BY ParcelID,                
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
	) AS row_num 
		FROM NVH
		
	) t
	WHERE row_num > 1
);
