-- my sel에서 
-- power BI
-- customer, product, salesorderheader, salesorderDetail
-- employee, productCategory, ProductSubCategory, SalesTerritory

-- localhost
-- adventureworks

select customerid, TerritoryID, customerType from customer;

select territoryid, Name, CountryRegionCode, 'Group', SalesYTD, SalesLastYear  from salesTerritory; 

# 업데이트 하려면 데이터창을 띄우고 해야한다.
update salesTerritory
set SalesYTD = SalesYTD*0.1
where territoryid between 1 and 5

