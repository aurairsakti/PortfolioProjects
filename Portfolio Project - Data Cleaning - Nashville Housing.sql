/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProject1..NashvilleHousing

--------------------------------------------------------------------
-- Standarize Date Format
select SaleDate, CONVERT(date, SaleDate)
from PortfolioProject1..NashvilleHousing

-- if this methods not working, then use ALTER TABLE to add new column
update NashvilleHousing
set SaleDate = convert(date, SaleDate)

-- add new column SaleDateStd convert SaleDate with standarized format
alter table NashvilleHousing
add SaleDateStd date;

update NashvilleHousing
set SaleDateStd = convert(date, SaleDate)

select SaleDateStd
from PortfolioProject1..NashvilleHousing


--------------------------------------------------------------------
-- Populate Property Address data

select *
from PortfolioProject1..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- Find the same data with different UniqueID
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject1..NashvilleHousing a
join PortfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Update PrropertyAddress is Null with Property address is not Null
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject1..NashvilleHousing a
join PortfolioProject1..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out address into individual columns (Address, City, State)

select PropertyAddress
from PortfolioProject1..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- Substring
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address

from PortfolioProject1..NashvilleHousing

-- Add new column for Addresses
alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

select *
from PortfolioProject1..NashvilleHousing


-- Breaking out address into individual columns (Address, City, State) - OwnerAddress - with PARSENAME

select OwnerAddress
from PortfolioProject1..NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
from PortfolioProject1..NashvilleHousing

-- Add new column Owner Address
alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


select *
from PortfolioProject1..NashvilleHousing


-------------------------------------------------------------------------
-- Change Y and N to Yes and No in "SoldAsVacant" field

-- Find Y / N
select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject1..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject1..NashvilleHousing

-- Update NashvilleHousing table SoldAsVacant Y/N --> Yes/No
update NashvilleHousing
set SoldAsVacant =
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


-------------------------------------------------------------------------
-- Remove Duplicate

-- Find the duplicates with CTE
with RowNumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by UniqueID ) row_num

from PortfolioProject1..NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

-- DELETE the duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() over (
partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by UniqueID ) row_num

from PortfolioProject1..NashvilleHousing
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1

-- check if the duplicates still exist
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-------------------------------------------------------------------------
-- Delete unused columns

select *
from PortfolioProject1..NashvilleHousing

alter table PortfolioProject1..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject1..NashvilleHousing
drop column SaleDate