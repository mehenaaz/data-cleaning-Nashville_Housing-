# Clean Data Using SQL & MYSQL queries On "Nashville Housing Dataset"

This readme is to give the description of  the dataset and to  show the comparisons between sql queries of two tools: MySQL Workbench 8.0 CE & Microsoft SQL Server Management Studio 18.

##### Dataset Description:

This dataset contains Information of all about  customer  and  details of a house renting.

##### Columns:

UniqueID, ParcelID,Landuse,Property Address,SaleDate,SalePrice,LegalRefrences,SoldAsVacant,OwnerName,Owner Address,Acreage,TAxDistrict,LandValue,BuildingValue.TotalValue,YearBuilt,Bedrooms,Fullbath,Halfbath.

##### Aim:

- Standardize Date Format
- Populate Property Address Data
- Breaking out Address into Individual Columns (Address, City, State)
- Change Y and N to Yes and No in "Sold as Vacant" field
- Delete Duplicates
- Delete Unused Columns



##### Tools:

MySQL Workbench 8.0 CE

Microsoft SQL Server Management Studio 18



##### Comparison Between Queries of MySQL Workbench & Microsoft SQL Server:

​			

| SQL SERVER                                                   | MYSQL                                                        |
| :----------------------------------------------------------- | :----------------------------------------------------------- |
| select SaleDate,**convert(Date,SaleDate)**                   | select SaleDate,**convert(SaleDate,Date)**                   |
| **UPDATE** a<br/>**SET** PropertyAddress=**ISNULL**(a.PropertyAddress,b.PropertyAddress) <br/>FROM portfolio_1.dbo.NashvilleHousing a <br/>**JOIN**portfolio_1.dbo.NashvilleHousing b <br/>ON a.ParcelID=b.ParcelID<br/>AND a.[UniqueID ]<>b.[UniqueID ] <br/>**WHERE** a.PropertyAddress is null; | **UPDATE** NVH a -- labelling as a<br/>**JOIN**NVH b -- labelling as "b"<br/>ON a.ParcelID=b.ParcelID<br/>AND a.UniqueID <>b.UniqueID <br/>**SET **a.PropertyAddress=**IFNULL**(a.PropertyAddress,b.PropertyAddress) <br/>**WHERE** a.PropertyAddress is null; |
| SUBSTRING(PropertyAddress,1,**CHARINDEX**(',',PropertyAddress)-1) as Address | SUBSTRING(PropertyAddress,1,**LOCATE**(',',PropertyAddress)-1) as Address |
| **LEN**(PropertyAddress))                                    | **CHAR_LENGTH**(RTRIM(PropertyAddress)                       |
| **PARSENAME**(REPLACE(OwnerAddress,',','.'),3)               | **SUBSTRING_INDEX**(OwnerAddress,',',1)                      |
| WITH RowNumCTE AS(<br/>Select *,<br/>	**ROW_NUMBER() OVER** (                <br/>	**PARTITION BY** ParcelID,                <br/>				 PropertyAddress,<br/>				 SalePrice,<br/>				 SaleDate,<br/>				 LegalReference<br/>				 ORDER BY<br/>					UniqueID<br/>					) row_num<br/><br/>From NashvilleHousing)<br/><br/>**SELECT** *<br/>From RowNumCTE<br/>Where row_num > 1<br/>Order by PropertyAddress | #check for duplicates:<br/>**SELECT** UniqueID, <br/>    **ROW_NUMBER() OVER** ( <br/>		**PARTITION BY**  ParcelID,                <br/>				 PropertyAddress,<br/>				 SalePrice,<br/>				 SaleDate,<br/>				 LegalReference<br/>				 ORDER BY<br/>					UniqueID<br/>	) AS row_num <br/>FROM NVH; |
| #Remove Duplicates<br/>WITH RowNumCTE AS(<br/>Select *,<br/>	**ROW_NUMBER() OVER** (                  <br/>	**PARTITION BY** ParcelID,               <br/>				 PropertyAddress,<br/>				 SalePrice,<br/>				 SaleDate,<br/>				 LegalReference<br/>				 ORDER BY<br/>					UniqueID<br/>					) row_num<br/><br/>FROM NashvilleHousing)<br/><br/>**DELETE**<br/>**FROM** RowNumCTE<br/>**WHERE** row_num > 1 | **DELETE** FROM NVH  <br/>**WHERE** <br/>	UniqueID IN (<br/>	SELECT <br/>		UniqueID <br/>	**FROM** (<br/>		SELECT <br/>			UniqueID,<br/>			**ROW_NUMBER() OVER** (<br/>				**PARTITION BY**ParcelID,                <br/>				 PropertyAddress,<br/>				 SalePrice,<br/>				 SaleDate,<br/>				 LegalReference<br/>				 ORDER BY<br/>					UniqueID<br/>	) AS row_num <br/>		FROM NVH<br/>        ) t<br/>WHERE row_num > 1); |
|                                                              |                                                              |



##### Courtesy:https://www.youtube.com/watch?v=8rO7ztF4NtU
