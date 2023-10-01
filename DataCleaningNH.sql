select top 1000 * from NashvilleHousing
--standardize date format

select top 1000 FORMAT(SaleDate, 'MM-dd-yyyy') from NashvilleHousing

update NashvilleHousing
Set SaleDate = FORMAT(SaleDate, 'MM-dd-yyyy')

alter table nashvillehousing alter column saledate date

SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'NashvilleHousing'

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'NashvilleHousing'

-------------
--------------------------------------
----------------------------

--populate property address data

select * from NashvilleHousing where PropertyAddress is null

select  p1.ParcelID, p2.ParcelID, p1.PropertyAddress, p2.PropertyAddress from NashvilleHousing p1 inner join NashvilleHousing p2 on p1.ParcelID=p2.ParcelID and p1.UniqueID<>p2.UniqueID where p1.PropertyAddress is null

select  p1.ParcelID, p2.ParcelID, isnull(p1.propertyaddress,p2.PropertyAddress), p2.PropertyAddress from NashvilleHousing p1 join NashvilleHousing p2 on p1.ParcelID=p2.ParcelID and p1.UniqueID<>p2.UniqueID where p1.PropertyAddress is null

	--we know that the parcel id is tied to only one address so we can find the address that matches the parcel id and set it to the missing addresses
update p1
set PropertyAddress = p2.propertyaddress
from NashvilleHousing p1 join NashvilleHousing p2 on p1.ParcelID=p2.ParcelID and p1.UniqueID<>p2.UniqueID 
where p1.PropertyAddress is null

--breaking out address into individual columns(address, city, state)
select propertyaddress from NashvilleHousing

select substring(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) Address 
, substring(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) City from NashvilleHousing

alter table NashvilleHousing add propertysplitaddress Nvarchar(255)

update NashvilleHousing set propertysplitaddress = substring(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1)  

alter table NashvilleHousing add propertysplitcity Nvarchar(255)

update NashvilleHousing set propertysplitcity = substring(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

select * from NashvilleHousing

	--owner address

select OwnerAddress from NashvilleHousing

select 
parsename(REPLACE(OwnerAddress, ',', '.'),3),
parsename(REPLACE(OwnerAddress, ',', '.'),2),
parsename(REPLACE(OwnerAddress, ',', '.'),1)


from NashvilleHousing

alter table NashvilleHousing add ownersplitaddress Nvarchar(255)

update NashvilleHousing set ownersplitaddress = parsename(REPLACE(OwnerAddress, ',', '.'),3)

alter table NashvilleHousing add ownersplitcity Nvarchar(255)

update NashvilleHousing set ownersplitcity = parsename(REPLACE(OwnerAddress, ',', '.'),2)

alter table NashvilleHousing add ownersplitstate Nvarchar(255)

update NashvilleHousing set ownersplitstate = parsename(REPLACE(OwnerAddress, ',', '.'),1)

--change Y and N to yes and no in 'sold as vacant' field
select distinct(SoldAsVacant),count(soldasvacant) from NashvilleHousing group by SoldAsVacant

--[extra]some overlap here
select distinct(LandUse) from NashvilleHousing order by LandUse

--remove duplicates
select * from NashvilleHousing



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

From NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE where row_num > 1 order by PropertyAddress



