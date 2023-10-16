--standardize date format
update NashvilleHousing
Set SaleDate = FORMAT(SaleDate, 'MM-dd-yyyy')

alter table nashvillehousing alter column saledate date

--populate property address data 
--we can find address using parcel id where parcel id is paired with addrress for oather entries
update p1
set PropertyAddress = p2.propertyaddress
from NashvilleHousing p1 join NashvilleHousing p2 on p1.ParcelID=p2.ParcelID and p1.UniqueID<>p2.UniqueID 
where p1.PropertyAddress is null

--breaking out address into individual columns(address, city, state)
alter table NashvilleHousing add propertysplitaddress Nvarchar(255)

update NashvilleHousing set propertysplitaddress = substring(propertyaddress,1,CHARINDEX(',',PropertyAddress)-1)  

alter table NashvilleHousing add propertysplitcity Nvarchar(255)

update NashvilleHousing set propertysplitcity = substring(propertyaddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

alter table NashvilleHousing add ownersplitaddress Nvarchar(255)

update NashvilleHousing set ownersplitaddress = parsename(REPLACE(OwnerAddress, ',', '.'),3)

alter table NashvilleHousing add ownersplitcity Nvarchar(255)

update NashvilleHousing set ownersplitcity = parsename(REPLACE(OwnerAddress, ',', '.'),2)

alter table NashvilleHousing add ownersplitstate Nvarchar(255)

update NashvilleHousing set ownersplitstate = parsename(REPLACE(OwnerAddress, ',', '.'),1)





