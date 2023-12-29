select *
from portfolio_project.dbo.NashvilleHousing

-- Standardize date formats----------------------------------------------------------------------------

select  SaleDate,convert(date,saledate)
from portfolio_project.dbo.NashvilleHousing

ALTER TABLE portfolio_project.dbo.NashvilleHousing
ALTER COLUMN saledate date;

select saledate
from NashvilleHousing

----------------------------------------------------------------------------

-- Populating Property Address
select  a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from portfolio_project.dbo.NashvilleHousing a
join portfolio_project.dbo.NashvilleHousing b
     on a.parcelid=b.parcelid
	 and a.uniqueid<>b.uniqueid
where a.propertyaddress is null
order by a.parcelid

update a
set propertyaddress=isnull(a.propertyaddress,b.propertyaddress)
from portfolio_project.dbo.NashvilleHousing a
join portfolio_project.dbo.NashvilleHousing b
     on a.parcelid=b.parcelid
	 and a.uniqueid<>b.uniqueid
where a.propertyaddress is null


--------------------------------------------------------------------------------------------------
-- Breaking address into Individual Columns (Address,City,State)

select
substring(propertyaddress,1,charindex(',',propertyaddress)-1) as address,
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as state
from portfolio_project.dbo.NashvilleHousing
order by state

ALTER TABLE portfolio_project.dbo.NashvilleHousing
add splitted_address nvarchar(255)

ALTER TABLE portfolio_project.dbo.NashvilleHousing
add splitted_state nvarchar(255)

update portfolio_project.dbo.NashvilleHousing
set splitted_address=substring(propertyaddress,1,charindex(',',propertyaddress)-1),
splitted_state=substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))

select
 splitted_address, splitted_state
from portfolio_project.dbo.NashvilleHousing


-------Doing for the owner address---------------------------------------
select
 owneraddress
from portfolio_project.dbo.NashvilleHousing

select
 parsename(Replace(owneraddress,',','.'),3) as owner_address,
 parsename(Replace(owneraddress,',','.'),2) as owner_city,
 parsename(Replace(owneraddress,',','.'),1) as owner_state
from portfolio_project.dbo.NashvilleHousing
order by owner_city

ALTER TABLE portfolio_project.dbo.NashvilleHousing
add owner_address nvarchar(255)

ALTER TABLE portfolio_project.dbo.NashvilleHousing
add owner_city nvarchar(255)

ALTER TABLE portfolio_project.dbo.NashvilleHousing
add owner_state nvarchar(255)

update portfolio_project.dbo.NashvilleHousing
set owner_address=parsename(Replace(owneraddress,',','.'),3),
owner_city=parsename(Replace(owneraddress,',','.'),2),
owner_state=parsename(Replace(owneraddress,',','.'),1)

select *
from portfolio_project.dbo.NashvilleHousing


--- Change Y and N to Yes and No in 'Sold as Vacant Field'-------------------

select soldasvacant,count(*)
from portfolio_project.dbo.NashvilleHousing
group by soldasvacant

select soldasvacant,
case when soldasvacant='N' then 'No'
     when soldasvacant='Y' then 'Yes'
	 else soldasvacant
end
from portfolio_project.dbo.NashvilleHousing
group by soldasvacant

update NashvilleHousing
set soldasvacant=case when soldasvacant='N' then 'No'
     when soldasvacant='Y' then 'Yes'
	 else soldasvacant
end


----Removing Duplicate Data------------------------------------
with cte as (
select *,
row_number() over(partition by parcelid,saledate,saleprice,legalreference,saledate
order by uniqueid)row_num
from NashvilleHousing)
select *
from cte
where row_num>1


with cte as (
select *,
row_number() over(partition by parcelid,saledate,saleprice,legalreference,saledate
order by uniqueid)row_num
from NashvilleHousing)
delete
from cte
where row_num>1


----------------------------------------------------------------------------------------------------
-- Deleting Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column propertyaddress,owneraddress,taxdistrict