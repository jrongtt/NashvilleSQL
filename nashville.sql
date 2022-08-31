SELECT * FROM Nashville_Housing.nashville2;


-- 1: Standardize Date Format:

SET SQL_SAFE_UPDATES = 0;



ALTER TABLE Nashville_Housing.nashville2
ADD COLUMN SaleDateConverted Date;

UPDATE Nashville_Housing.nashville2
SET SaleDateConverted = STR_TO_DATE(SaleDate,'%M %d,%Y');

SELECT SaleDateConverted FROM Nashville_Housing.nashville2;

SET SQL_SAFE_UPDATES = 1;


-- 2: Populate Property Address data

SELECT *
FROM  Nashville_Housing.nashville2;





-- This joins the same table to itself and when parcel id are the same and unique id is different
-- then we populate
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing.nashville2 a
JOIN Nashville_Housing.nashville2 b
	on a.ParcelID = b.ParcelID
    AND a.`UniqueID` <> b.`UniqueID`
WHERE a.PropertyAddress IS NULL;



-- We didn't need to update anything since there was no nulls

-- 3: Breakingout Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Nashville_Housing.nashville2;

SELECT 
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress)) as Address2
FROM Nashville_Housing.nashville2;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE Nashville_Housing.nashville2
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashville_Housing.nashville2
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1);

ALTER TABLE Nashville_Housing.nashville2
ADD PropertySplitCity Nvarchar(255);

UPDATE Nashville_Housing.nashville2
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, LENGTH(PropertyAddress));

SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM Nashville_Housing.nashville2;


-- Owner Address

ALTER TABLE Nashville_Housing.nashville2
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashville_Housing.nashville2
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress)-1);





ALTER TABLE Nashville_Housing.nashville2
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nashville_Housing.nashville2
SET OwnerSplitCity = SUBSTRING(SUBSTRING_INDEX(OwnerAddress, ',', 2), LENGTH(OwnerSplitAddress)+2, LENGTH(SUBSTRING_INDEX(OwnerAddress, ',', 2)));

ALTER TABLE Nashville_Housing.nashville2
ADD OwnerSplitState Nvarchar(255);

UPDATE Nashville_Housing.nashville2
SET OwnerSplitState = 'TN';

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState, OwnerAddress
FROM Nashville_Housing.nashville2;

SELECT * FROM Nashville_Housing.nashville2;


-- 4: Change Y and N to Yes and No in 'Sold as Vacant'


-- First inspect the Yes, No, Y, and Ns
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM Nashville_Housing.nashville2 
GROUP BY SoldAsVacant
ORDER BY 2;


UPDATE Nashville_Housing.nashville2
SET SoldAsVacant =  CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO'
    ELSE SoldAsVacant
    END;


-- 5: Removes Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
				SalePrice,
				SaleDate,
                LegalReference
                ORDER BY UniqueID) row_num
FROM Nashville_Housing.nashville2
 -- ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;
-- ORDER BY PropertyAddress;




