Select *
from Nashvile_housing

Select *
from Nashvile_housing
--Where PropertyAddress is null 
order by 1 desc

-- Property address 
Select a.ParcelID , b.PropertyAddress , b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashvile_housing as a
join Nashvile_housing as b 
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null 

select *
from Nashvile_housing
where PropertyAddress is null 

Update a
Set PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from Nashvile_housing as a
join Nashvile_housing as b 
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null 

--Breaking the property address 
Select PropertyAddress , OwnerAddress
from Nashvile_housing

Select 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1)  As address 
From Nashvile_housing

Select 
SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1)  As address,
SUBSTRING(PropertyAddress , CHARINDEX(',' , PropertyAddress)+1 ,LEN(PropertyAddress )) As State
From Nashvile_housing

alter table Nashvile_housing
Add Propertysplitcity nvarchar(255) null 

alter table Nashvile_housing
Add PropertysplitAddress nvarchar(255) null 

Update Nashvile_housing
Set PropertysplitAddress = SUBSTRING(PropertyAddress , 1 , CHARINDEX(',' , PropertyAddress)-1)

select PropertysplitAddress 
from Nashvile_housing

Select PARSEname(Replace(OwnerAddress,',','.'),3),
PARSEname(Replace(OwnerAddress,',','.'),2),
PARSEname(Replace(OwnerAddress,',','.'),1)
from Nashvile_housing

alter table Nashvile_housing
Add OwnersplitAddress nvarchar(255) null 

Update Nashvile_housing
Set OwnersplitAddress = PARSEname(Replace(OwnerAddress,',','.'),3)

alter table Nashvile_housing
Add OwnersplitCity nvarchar(255) null 

Update Nashvile_housing
Set OwnersplitCity = PARSEname(Replace(OwnerAddress,',','.'),2)

alter table Nashvile_housing
Add OwnersplitStates nvarchar(255) null

Update Nashvile_housing
Set OwnersplitStates = PARSEname(Replace(OwnerAddress,',','.'),1)

--vacant 
select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Nashvile_housing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
Case
when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN  'No'
Else SoldAsVacant
End
from Nashvile_housing
Where SoldAsVacant = 'N'

Update Nashvile_housing
Set SoldAsVacant = Case
when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN  'No'
Else SoldAsVacant
End

--remove the duplicate

 WiTH Rownumbercte AS(
 Select *,
	ROW_NUMBER () Over ( Partition by ParcelID , PropertyAddress ,SalePrice,
	SaleDate, LegalReference ORDER BY UniqueID) row_num
from Nashvile_housing)

 Select *
from Rownumbercte
WHERE row_num > 1
--ORder by 4 

--Drop Column 

alter table Nashvile_housing
Drop column PropertyAddress , OwnerAddress , TaxDistrict




