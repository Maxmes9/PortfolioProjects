

SELECT *
  FROM NashvilleHousing

 -- Standarize Date Format

 SELECT SaleDateConverted, CONVERT(Date,SaleDate)
 FROM NashvilleHousing

 UPDATE NashvilleHousing
 SET SaleDate = CONVERT(Date,SaleDate)

 ALTER TABLE NashvilleHousing
 Add SaleDateConverted Date;

  UPDATE NashvilleHousing
 SET SaleDateConverted = CONVERT(Date,SaleDate)

 --Populate Property Address Data

 SELECT *
 FROM
	NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
	NashvilleHousing AS a
JOIN NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 

-- Breaking Out Address Into Individual Columns (Address,City,State)

 SELECT PropertyAddress
 FROM
	NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

--City And getting rid of the comma

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1 ) AS Address
FROM
	NashvilleHousing

--USING SUBSTRINGS

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS State
FROM
	NashvilleHousing

ALTER TABLE NashvilleHousing
 Add PropertySplitAddress nvarchar (255);

  UPDATE NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
 Add PropertyCity nvarchar (255);

  UPDATE NashvilleHousing
 SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT * 
FROM
	NashvilleHousing


--USING PARSENAME

SELECT OwnerAddress
FROM
	NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM
	NashvilleHousing

ALTER TABLE NashvilleHousing
 Add OwnerSplitAddress nvarchar (255);

  UPDATE NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
 Add OwnerSplitCity nvarchar (255);

  UPDATE NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
 Add OwnerSplitState nvarchar (255);

  UPDATE NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 SELECT*
 FROM
	NashvilleHousing

-- CHANGE Y and N to Yes and No in "SOLD AS VACANT" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM
	NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM 
	NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				   WHEN SoldAsVacant = 'N' THEN 'No'
				   ELSE SoldAsVacant
				   END

--Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) AS Run_num

FROM
	NashvilleHousing
--ORDER BY ParcelId
)
SELECT *
FROM
	RowNumCTE
WHERE Run_num >1
ORDER BY PropertyAddress

--DELETE UNUSED COLUMNS

SELECT * 
FROM
	NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

