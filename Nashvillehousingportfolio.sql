
--Cleaning data in SQL queries

select *
from NashvilleHousing

-- standardizing date format

--method 1
select SaleDate
from NashvilleHousing

select SaleDate, CONVERT(Date, SaleDate)
from NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- method 2 in case method 1 does not work

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

select SaleDateConverted, CONVERT(Date, SaleDate)
from NashvilleHousing

--method 2 actually worked in this case


--populating property address data
select *
from NashvilleHousing
where PropertyAddress is Null
order by ParcelID

--looking through the whole data, you would find instances where 2 or 
-- parcelID and PropertyAdress are the same
select *
from NashvilleHousing
--where PropertyAddress is Null
order by ParcelID

--joining table to itself where the parcelID is the same but not the same row
select A.ParcelID, A.PropertyAddress,B.ParcelID, B.PropertyAddress
from NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]

--looling at where A.parcelID is NULL

--below script will help us find instances where property address in A is NULL and 
--property address in B has a given address even though both parcelID are the same

select A.ParcelID, A.PropertyAddress,B.ParcelID, B.PropertyAddress
from NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL

-- below script will help populate the NULL property address of A with that of
-- property address in B where both parcelID are the same
select A.ParcelID, A.PropertyAddress,B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress) 
from NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL

--updating our table
UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL

--RUNNING THE SCRIPT AGAIN AFTER UPDATE SHOWS NO MORE NULLS
select A.ParcelID, A.PropertyAddress,B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress) 
from NashvilleHousing A
JOIN NashvilleHousing B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL

--breaking out address into individual columns (address, city, state)
select PropertyAddress
from NashvilleHousing

select 
SUBSTRING(propertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(propertyAddress)) as address
from NashvilleHousing


ALTER TABLE NashvilleHousing
ADD propertySplitAddress nvarchar(255);

update NashvilleHousing
SET propertySplitAddress = SUBSTRING(propertyAddress,1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD propertySplitCity nvarchar(255);

update NashvilleHousing
SET propertySplitCity = SUBSTRING(propertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(propertyAddress))

select *
from NashvilleHousing
-- After running above scripts, the proprtyAddress would be split by city and by address and shown at the last column on the table

--splitting ownerAdress column
select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from NashvilleHousing

--PARSENAME can be used in the place of SUIBSTRING and it is more convinient to use 
--PARSENAME operates backward

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select *
from NashvilleHousing


--change Y and N to YES and NO in the sold as vacant field

select  Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

select SoldAsVacant
 ,case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   End
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
                        when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
	                    End
-- after running the script for update Nashville, run the script for select distinct to see changes effected

--removing duplicates from sql server

select *,
 ROW_NUMBER() OVER (
 PARTITION BY parcelID,
              propertyAddress,
			  SaleDate,
			  LegalReference
			  ORDER BY
			          UniqueID
					          ) Row_Num
 FROM NashvilleHousing
 ORDER BY ParcelID
--above query was used to get duplicate data 
--any Row_Num above one is duplicate

--using above query in a CTE helps to get all duplicate rows

WITH RowNumCTE AS
(
select *,
 ROW_NUMBER() OVER (
 PARTITION BY parcelID,
              propertyAddress,
			  SaleDate,
			  LegalReference
			  ORDER BY
			          UniqueID
					          ) Row_Num
 FROM NashvilleHousing
 --ORDER BY ParcelID
 )
 select *
 from RowNumCTE
 where Row_Num > 1
 order by PropertyAddress
 -- above query shows us all duplicate rows in the data set

 -- below query deletes all the duplicate rows

 WITH RowNumCTE AS
(
select *,
 ROW_NUMBER() OVER (
 PARTITION BY parcelID,
              propertyAddress,
			  SaleDate,
			  LegalReference
			  ORDER BY
			          UniqueID
					          ) Row_Num
 FROM NashvilleHousing
 --ORDER BY ParcelID
 )
 DELETE
 from RowNumCTE
 where Row_Num > 1
 --order by PropertyAddress

 -- CHECKING FOR DUPLICATES SHOWS ZERO DUPLICATE ROWS


select *
from NashvilleHousing
order by 1

--Deleting unwanted columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,  PropertyAddress, TaxDistrict,SaleDate


