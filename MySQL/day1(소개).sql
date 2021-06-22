use adventureworks ;


select * from salesorderheader;


select * from salesorderdetail;


select soh.SalesOrderID, soh.OrderDate, sod.salesOrderid, ProductID, OrderQty
from salesorderheader soh join salesorderdetail sod
on soh.SalesOrderID = sod.SalesOrderIDsalesorderheader;


select sod.productid, p.productid, p.name 
from salesorderdetail sod join product p
on sod.productid = p.productid;


select sod.productid, p.productid, p.name 
from salesorderdetail sod left outer join product p
on sod.productid = p.productid;


select sod.productid, p.productid, p.name 
from salesorderdetail sod right outer join product p
on sod.productid = p.productid
where sod.productid is null;


