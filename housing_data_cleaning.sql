----------------------------------------------------------
--display the data
select *
from PortfolioProject.dbo.austinHousingData

----------------------------------------------------------
--extract sale date
update PortfolioProject.dbo.austinHousingData
set latest_saledate = convert(Date,latest_saledate)

--add the new required columns into the data
alter table PortfolioProject.dbo.austinHousingData
add saleDate Date, full_address varchar(200);
go

--add data into the new column
update PortfolioProject.dbo.austinHousingData
set saleDate = CONVERT(Date,latest_saledate)

----------------------------------------------------------
--order the data by zpid
select *
from PortfolioProject.dbo.austinHousingData
order by zpid

--address value if any of the fields are NULL
update PortfolioProject.dbo.austinHousingData
set full_address = 'Missing address details'
from PortfolioProject.dbo.austinHousingData
where streetAddress is null
and city is null
and zipcode is null

--if no null then get the whole address
update PortfolioProject.dbo.austinHousingData
set full_address = concat(streetAddress,',',upper(left(city,1))+lower(substring(city,2,len(city))),',',zipcode)
from PortfolioProject.dbo.austinHousingData
where streetAddress is not null 
and city is not null 
and zipcode is not null

select * from PortfolioProject.dbo.austinHousingData

----------------------------------------------------------
--round the value to 2 decimals
update PortfolioProject.dbo.austinHousingData
set avgSchoolDistance = round(avgSchoolDistance,2),
avgSchoolRating = round(avgSchoolRating,2)
from PortfolioProject.dbo.austinHousingData

----------------------------------------------------------
--check duplicates and delete them
with RowNumCTE as(
select *,
ROW_NUMBER() over(
partition by zpid,
full_address,
saleDate
order by zpid
)row_num
from PortfolioProject.dbo.austinHousingData
)
 --delete the duplicates
Delete
from RowNumCTE
where row_num > 1

--check of any more duplicates
select *
from RowNumCTE
where row_num > 1
order by full_address

----------------------------------------------------------
--drop not required columns

--display the data
select *
from PortfolioProject.dbo.austinHousingData

--copy data into another table
select *
into cleanedAustinHousingData
from PortfolioProject.dbo.austinHousingData

--display copied data table
select * from cleanedAustinHousingData

--drop the columns
alter table cleanedAustinHousingData
drop column latest_saledate, description






--check if zpid is null or if address is null
--select * from PortfolioProject.dbo.austinHousingData
--where zpid is null or city is null or zipcode is null

--if null
--update PortfolioProject.dbo.austinHousingData
--set full_address = ISNULL(streetAddress,'Null')
--from PortfolioProject.dbo.austinHousingData
--alter table PortfolioProject.dbo.austinHousingData
--drop column full_address;