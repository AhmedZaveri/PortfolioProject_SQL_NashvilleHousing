--CLEANING DATA IN SQL QUERIES

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData

--Standardize Date Format

SELECT SaleDate, CONVERT(DATE, Saledate) 
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add SaleDateConverted Date

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET SaleDateConverted = CONVERT(DATE, Saledate)

SELECT SaleDateConverted, CONVERT(DATE, Saledate) 
FROM PortfolioProject.dbo.NashvilleHousingData

--Populate Property Address Data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousingData

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData
WHERE PropertyAddress IS NULL

SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into Individual Columns (Address, City, State)
--Property Address Split Using SUBSTRING

SELECT PropertyAddress
From PortfolioProject.dbo.NashvilleHousingData

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))  AS City
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData 
ADD PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD PropertySplitCity nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Owner Address Split Using PARSENAME

SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City, 
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
ADD OwnerSplitState nvarchar(255)

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

--Change Y and N to Yes and No in "Sold as Vacant" Field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousingData
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousingData 

UPDATE PortfolioProject.dbo.NashvilleHousingData
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousingData 

--REMOVE DUPLICATES USING WINDOW FUNCTIONS

--Use CTE
WITH RowNumCTE AS
(
	SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as RowNum
	FROM PortfolioProject.dbo.NashvilleHousingData
	--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE RowNum > 1
ORDER BY PropertyAddress

--Deleting duplicates by swapping DELETE keyword with SELECT
WITH RowNumCTE AS
(
	SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) as RowNum
	FROM PortfolioProject.dbo.NashvilleHousingData
	--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE RowNum > 1

--Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData