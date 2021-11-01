
use portfolio_1;
select * from portfolio_1.dbo.NashvilleHousing;

-------------------Standarize Date Format------------------
select SaleDate,convert(Date,SaleDate) 
from portfolio_1.dbo.NashvilleHousing;
--update NashvilleHousing               --(this query didnot work)
--set SaleDate=convert(Date,SaleDate);  --(so,we go for Alter table)

Alter Table NashVilleHousing
Add SaleDateConverted Date; --add a new column

update NashvilleHousing
set SaleDateConverted=convert(Date,SaleDate);

select SaleDateConverted,convert(Date,SaleDate)
from portfolio_1.dbo.NashvilleHousing;

select SaleDateConverted from portfolio_1.dbo.NashvilleHousing;

select * from portfolio_1.dbo.NashvilleHousing;

--************Populate property address data*************

select PropertyAddress from portfolio_1.dbo.NashvilleHousing;

select PropertyAddress from portfolio_1.dbo.NashvilleHousing 
where PropertyAddress is Null; --check for null

--usually we remove null values but if we check the whole table we can see thatthe corresponding values
--for null rows are important that we cannot simply remove the null values

select * from portfolio_1.dbo.NashvilleHousing 
where PropertyAddress is Null; --check the whole table where  property address is null


-- instead of removing null values we can populate address on those null values
--duplicate values can be used to populate address.
--if a value (say parceID) has a address and a same parcelid doesnot have address i.e Null, we can populate the address 
--from the duplicated parcel id.


select * from portfolio_1.dbo.NashvilleHousing 
order by ParcelID;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from portfolio_1.dbo.NashvilleHousing a --labelling as "a"
Join portfolio_1.dbo.NashvilleHousing b -- labelling as "b"
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ];--"<>" not equal to
--join the table to itself and return a result where parcel ids are equal but unique ids are different.

/*select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from portfolio_1.dbo.NashvilleHousing a --labelling as "a"
Join portfolio_1.dbo.NashvilleHousing b -- labelling as "b"
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] */
where a.PropertyAddress is null; -- check for only null

Update a 
Set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress) --update the null values on property address.If a.propertyaddress is null replace the null with b.propertyaddress.thats why we use ISNULL.
from portfolio_1.dbo.NashvilleHousing a --labelling as "a"
Join portfolio_1.dbo.NashvilleHousing b -- labelling as "b"
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] 
where a.PropertyAddress is null;

--now agaain check for null
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from portfolio_1.dbo.NashvilleHousing a --labelling as "a"
Join portfolio_1.dbo.NashvilleHousing b -- labelling as "b"
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ] 
where a.PropertyAddress is null; 
--there are no null values.So,the coulmn has been updated successfully.


--*************Breaking out Property address into Individula columns(Address,City,State)**********
select PropertyAddress from portfolio_1.dbo.NashvilleHousing;

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from portfolio_1.dbo.NashvilleHousing;

Alter Table portfolio_1.dbo.NashvilleHousing
Add PropertyAddress_RoadNO Nvarchar(255)
Update portfolio_1.dbo.NashvilleHousing
Set PropertyAddress_RoadNO =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


Alter Table portfolio_1.dbo.NashvilleHousing
Add PropertyAddress_City Nvarchar(255)
Update portfolio_1.dbo.NashvilleHousing
Set PropertyAddress_City =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))

select * from NashvilleHousing;

--**********************Breaking out Owner Address into individual col for address,city************
select OwnerAddress from NashvilleHousing;
--select PARSENAME (REPLACE(OwnerAddress,',','.'),3),
-- PARSENAME (REPLACE(OwnerAddress,',','.'),2),
-- PARSENAME (REPLACE(OwnerAddress,',','.'),1) from NashvilleHousing;       

--       We can split the owneraddress column using PARSENAME funtion.PARSENAME function to split delimited data.it also works with 'period' delimiter.
--For this reason we replace the comma delimiter with period.It separetes things backwards.thats why , we write 3,2,1 for getting our results onwards.


--- now we Alter and update table for owner address.
ALTER TABLE NashvilleHousing
Add Owner_Add_Roadno  Nvarchar(255)

update NashvilleHousing
set Owner_Add_Roadno=PARSENAME (REPLACE(OwnerAddress,',','.'),3) 


ALTER TABLE NashvilleHousing
Add Owner_Add_city  Nvarchar(255)

update NashvilleHousing
set Owner_Add_city=PARSENAME (REPLACE(OwnerAddress,',','.'),2) 

ALTER TABLE NashvilleHousing
Add Owner_Add_State  Nvarchar(255)

update NashvilleHousing
set Owner_Add_State=PARSENAME (REPLACE(OwnerAddress,',','.'),1) 

select * from NashvilleHousing;

-- *************************  Change Y and N to Yes and No in "Sold as Vacant" field****************

select soldAsVacant from NashvilleHousing;
select * from NashvilleHousing;

select distinct soldAsVacant from NashvilleHousing;
-- the column contains 4 distinct values (N,Yes,Y,No).we need to keep the format same.

-- now check for the distinct values
select distinct (SoldAsVacant),count(SoldAsVacant) from NashvilleHousing
group by SoldAsVacant
order by 2;

--replace the values
select SoldAsVacant,
CASE when SoldAsVacant='Y' THEN 'Yes'
		 when SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END
from NashvilleHousing;

--  now update the table
Update NashvilleHousing
SET SoldAsVacant=CASE when SoldAsVacant='Y' THEN 'Yes'
		 when SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END

--************************Remove Duplicates********************
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (                   --ROW_NUMBER() function to assign a sequential integer to each row of a result set.
	PARTITION BY ParcelID,                -- partition on things should be unique to each row 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
--check for duplicates

-- remove
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

--****************remove unused columns**************
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;


Select * from NashvilleHousing;



















--************************************




















