
-- Cleaning Data in SQL

----------------------------------------------------------------------------------------------------------------------------------------------

select *
from SQLPROJECT..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize DATE Format:

--Converted SaleDate col from DATETIME to DATE datatype

select SaleDate
from SQLPROJECT..NashvilleHousing


ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE 


------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address:

select *
from SQLPROJECT..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from SQLPROJECT..NashvilleHousing a
JOIN SQLPROJECT..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from SQLPROJECT..NashvilleHousing a
JOIN SQLPROJECT..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out ADDRESS(Property and Owner) into Individual cols (Address, City, State) 

select PropertyAddress
from SQLPROJECT..NashvilleHousing

ALTER table NashvilleHousing add Address nvarchar(255)
ALTER table NashvilleHousing add City nvarchar(255)

UPDATE NashvilleHousing
set Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select OwnerAddress
from SQLPROJECT..NashvilleHousing


select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from SQLPROJECT..NashvilleHousing


ALTER table NashvilleHousing add OwnerSplitAddress nvarchar(255)
ALTER table NashvilleHousing add OwnerCity nvarchar(255)
ALTER table NashvilleHousing add OwnerState nvarchar(255)

UPDATE NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select OwnerAddress, OwnerSplitAddress, OwnerCity, OwnerState
from SQLPROJECT..NashvilleHousing



------------------------------------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in Sold as Vacant col:


select DISTINCT(SoldAsVacant)
from SQLPROJECT..NashvilleHousing

select DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
from SQLPROJECT..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

select SoldAsVacant, 
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from SQLPROJECT..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates:

WITH CTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY ParcelID, SaleDate, PropertyAddress ORDER BY UniqueID) AS row_num
    FROM NashvilleHousing
)
DELETE FROM NashvilleHousing WHERE UniqueID IN (
    SELECT UniqueID FROM CTE WHERE row_num > 1
)

