/*

Cleaning Data in SQL Queries

*/

Select *
From Portfolio_project.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDate, CONVERT(date, SaleDate)
From Portfolio_project.dbo.NashvilleHousing

Update Portfolio_project.dbo.NashvilleHousing
Set SaleDate = CONVERT(date, SaleDate)

ALTER TABLE Portfolio_project.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update Portfolio_project.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data

Select *
From Portfolio_project.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_project.dbo.NashvilleHousing a
join Portfolio_project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio_project.dbo.NashvilleHousing a
join Portfolio_project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From Portfolio_project.dbo.NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Portfolio_project.dbo.NashvilleHousing

ALTER TABLE Portfolio_project.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update Portfolio_project.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Portfolio_project.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update Portfolio_project.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From Portfolio_project.dbo.NashvilleHousing


Select OwnerAddress,
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
From Portfolio_project.dbo.NashvilleHousing

ALTER TABLE Portfolio_project.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio_project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Portfolio_project.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Portfolio_project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Portfolio_project.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Portfolio_project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From Portfolio_project.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), count(SoldAsVacant)
From Portfolio_project.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
end
From Portfolio_project.dbo.NashvilleHousing

update Portfolio_project.dbo.NashvilleHousing
set SoldAsVacant = case
when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
end


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From Portfolio_project.dbo.NashvilleHousing
)
select *
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns

Select *
From Portfolio_project.dbo.NashvilleHousing


ALTER TABLE Portfolio_project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



