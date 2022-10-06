Select * from PortfolioProject.dbo.NashvilleHousing



-- Standardize Date Format
-- Remove time from the end as column is in dateTime format

Select SaleDate, CONVERT(Date, SaleDate) from PortfolioProject.dbo.NashvilleHousing

--Not working
--Update NashvilleHousing
--Set SaleDate = CONVERT(Date, SaleDate)

--Working
Alter table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate) from PortfolioProject.dbo.NashvilleHousing




-- Populate Property Address data

Select * from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- ParcelId is same for same address, so if parcelId same, populate propertyAddress with same address
-- Understand again https://www.youtube.com/watch?v=8rO7ztF4NtU&list=PLUaB-1hjhk8H48Pj32z4GZgGWyylqv85f&index=3
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




-- Individual Columns for address
-- Substring and Character Index

Select PropertyAddress from PortfolioProject.dbo.NashvilleHousing

-- charindex gives position of , 
Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)) as Address,
CHARINDEX(',', PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing

Alter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)


Alter table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

Select PropertySplitAddress, PropertySplitCity from PortfolioProject.dbo.NashvilleHousing

Select ownerAddress from PortfolioProject.dbo.NashvilleHousing

-- Parse name and Replace

Select 
PARSENAME (Replace (OwnerAddress, ',', '.'), 3),
PARSENAME (Replace (OwnerAddress, ',', '.'), 2),
PARSENAME (Replace (OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing


Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME (Replace (OwnerAddress, ',', '.'), 3)


Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME (Replace (OwnerAddress, ',', '.'), 2)


Alter table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME (Replace (OwnerAddress, ',', '.'), 1)

Select * from PortfolioProject.dbo.NashvilleHousing



-- Change Y & N to Yes and No in SoldAsVacant

Select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
  Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end



-- Remove Duplicates
-- Look up Rank
-- CTE, windows function of partition by

With RowNumCTE as(
Select * ,
	Row_Number() over 
	(
	Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID
	) row_num
from PortfolioProject.dbo.NashvilleHousing
-- order by ParcelID (not inside CTE)
)
-- Select *
Delete
from RowNumCTE
where row_num > 1
-- order by PropertyAddress (Not with delete)




-- Delete Unsused Columns
-- Do not delete directly from raw data in real practice, create views and then use delete, update etc.

Select *
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, SaleDate