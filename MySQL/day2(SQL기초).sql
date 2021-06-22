use adventureworks;

-- sql 기본구조 

/** select
from table, view
where
group by
having
order by
**/


# 1
select employeeid, contactid, Loginid, managerid 
# * 를 통해 변수를 모두 호출하면 memory를 많이 차지한다.. 필요한 변수만 가져오는 걸 추천
# disk --> memory --> cpu
from employee 
limit 0, 5; # 1번행부터 5개를 보여주는 코드 (앞 숫자는 포함 x)


-- distinct
select distinct title # 중복 제외한 유니크한 값만 보고 싶을떄
from employee;
# 67개

select distinct title, gender
from employee;
# 93개

-- where
select distinct title, gender
from employee
-- where title = 'tool designer'
where title != 'tool designer'; # != 아니다

-- where title like 'tool designer'; tool designer인거 찾기
-- where title like '%tool designer'; tool designer로 끝나는 거 찾기  
-- where title like 'designer%';  designer로 시작하는거 찾기
-- where title like '%designer%';  중간에 designer가 있는거 찾기

-- where 수치형
-- where vacationhour = 10
-- where vacationhour != 10
-- where vacationhour >= 10 and vacationhour < 20
-- where vacationhour between 10 and 19 # between은 양 끝을 포함

-- 두 개의 where 조건
-- and, or

-- 'in', 'not in' filter
select * from employee
where managerid between 16 and 21;

-- 여기서 16과 21번만 가지고 오고싶다.
select * from employee
where managerid in (16, 21);
-- where managerid not in (16, 21); 16과 21만 제외 


-- null
select * from product
where size is null;
-- where size = 'null; 이렇게 하면 x 
-- where size is not null;


-- 정렬 order by
select * from employee
order by gender, hiredate desc;

select * from employee
order by 9, 10 desc; # select 열의 index부여해서 사용가능 but 웬만하면 사용하지말자 데이터가 여러개일경우 혼란...alter


-- quiz : employeePayhistory 테이블에서 시급(rate)이 높은 순서대로 20명만 출력!!
select * from employeePayhistory
order by rate desc
limit 0, 20;


--  병칭. (alias)
select employeeid as 사원번호 # 열 별칭
from employee 사원테이블; # 테이블 별칭

-- 집계함수 
-- count(), sum(), max(), min(), avg()
select count(*) from salesorderheader;

# 컬럼만 보고 싶을떄
select * from salesorderheader
where 1=0;

select count(*) as 총주문건수, max(orderdate) as 최근주문일 , min(orderdate) as 최초주문일, avg(totaldue) as 객단가 from salesorderheader;

# 테이블의 행의 수를 확인 가능
select count(distinct title) from employee;

# group by 에 따른 수 확인
select TerritoryID as 지역, count(*) as 총주문건수 from salesorderheader
group by TerritoryID
order by 총주문건수 desc;

select salesPersonID, TerritoryID, count(*) 
from salesorderheader
where salesPersonID is not null
group by salesPersonID, TerritoryID
order by salesPersonID, TerritoryID;
# 35건

select salesPersonID, TerritoryID, count(*) 
from salesorderheader
where salesPersonID is not null
group by salesPersonID, TerritoryID
having count(*) >= 10 # having은 집계된 열에서의 조건을 사용
order by salesPersonID, TerritoryID;
# 31

select SalesOrderID, count(*) as 주문건수
from salesOrderDetail
-- SalesOrderID 당 5개 이상의 건수가 있는 주분번호 (SalesOrderID)를 조회하는 쿼리는?  
group by SalesOrderID
having count(*) >= 5
order by count(*), SalesOrderID ;

-- salesorderdetail에서 각 물건당 2개 이상 구매한 건수가 
-- salesOrderId 당 5개 이상의 건수가 있는 주문번호(SalesOrderID)를 조회하는 쿼리는? 
select SalesOrderID, count(*) as 주문건수 
from salesOrderDetail
where OrderQty >= 2
group by SalesOrderID
having count(*) >= 5
order by count(*), SalesOrderID ;


-- join
-- 두개의 테이블을 붙이는 작업입니다.
-- 두개의 테이블을 컬럼의 개수가 늘어나는 방향으로 붙이게 된다. 
-- 관계형 데이터베이스에서 키를 기반으로 붙인다.

-- 레코드가 늘어나는 방향으로 붙이는 방법은? union, union all
-- 공공데이터가 일별 또는 월별, 연도별로 파일이 나눠져 있는 경우 

-- join
-- inner, outer join, full join
-- inner join --> 교집합, 두개의 테이블에서 모두 잇는 경우만 조회
-- left or right outer join --> 해당 위치의 테이블을 모두 가져오고
-- 				 				반대편 테이블중 없는 것은 null로 표현 

-- join 첫 번쨰, SalesOrderHeader와 SalesOrderDetail에서 
-- salesOrderHeader의 subtotal, taxamt, freight, totalamt,
-- salesOrderDetail의 Orderqty * unitPrice
select *
from salesOrderheader inner join salesOrderDetail on salesOrderheader.SalesOrderID = salesOrderDetail.SalesOrderID
limit 0, 30;

-- 별칭을 써서 표현
select Soh.SalesOrderID, salesorderdetailid, subtotal, taxamt, freight, totaldue ,  Orderqty * unitPrice
from salesOrderheader Soh inner join salesOrderDetail Sod 
on Soh.SalesOrderID = Sod.SalesOrderID;

-- outer join 는 방향성이 있다.  
-- salesOrderdetail 즉, 주문된 적이 없는 제품 코드는?
select sod.productid, p.productid, p.name
from salesorderdetail sod join product p
on sod.productid = p.productid;
# 121317

-- 제품은 있지만 한개도 팔리지 않은 제품 리스트 찾기
select sod.productid, p.productid, p.name
from salesorderdetail sod right outer join product p # p에 있지만 sod에 없는거
on sod.productid = p.productid
where sod.productid is null 
order by sod.productid;
# 121555중 238건이 sod에서 팔리지 않음


-- 3개 이상의 테이블 조인하기
select p.productid, p.name, pc.name, ps.name
from Product p join ProductSubcategory PS
on p.ProductSubCategoryID = PS.ProductSubCategoryID
join ProductCategory PC
on ps.ProductCategoryid = PC.ProductCategoryid;

-- view를 만듬
create view vw_salesreaseon as
select  sr.reasontype, sr.name,  count(*) as 건수
from salesorderheader soh join salesorderheadersalesreason sor
on soh.salesorderid = sor.salesorderid
join salesreason sr
on sor.salesreasonid = sr.salesreasonid
group by  sr.reasontype, sr.name
;

select * from vw_salesreaseon addressaddresstypeaddresstype
where 건수 > 1000 ; # 집계함수를 만들면 having 절을 통해서 조건을 걸지만 create view 를 만들면 where을 통해 확인 가능.


-- union and union all
-- union은 레코드가 증가하는 방법으로 병합
-- union과 union all의 차이는 전자는 distinct 포함이며, 후자는 모두 나온다.(세로 병합)
select salesorderid, orderdate, year(orderdate), subtotal, TaxAmt, duedate 
from salesorderheader
order by orderdate;

-- e commerce, iot 시계열 데이터가 넘쳐난다.
-- 데이터가 너무 많으면 쪼개놓는다 --> 파티셔닝(partition)
-- 주로 연단위로 나뉜다.alter
-- salesorderheader2001, salesorderheader2002, 

# view는 정보를 노출안시키기 위해서?? 만들면 0컬럼을 만들었다고 뜨나 막상 select절로 다시열면 볼 수 있음 
create view vw_주문테이블 as 
select * from (
	select salesorderid, orderdate, year(orderdate), subtotal, TaxAmt, duedate 
	from salesorderheader
	where year(orderdate) = 2001
	union
	select salesorderid, orderdate, year(orderdate), subtotal, TaxAmt, duedate 
	from salesorderheader
	where year(orderdate) = 2002
	union
	select salesorderid, orderdate, year(orderdate), subtotal, TaxAmt, duedate 
	from salesorderheader
	where year(orderdate) = 2003
	union
	select salesorderid, orderdate, year(orderdate), subtotal, TaxAmt, duedate 
	from salesorderheader
	where year(orderdate) = 2004
) a; # subquery 개념 

select * from vw_주문테이블;
















