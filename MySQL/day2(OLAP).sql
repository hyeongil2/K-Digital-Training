-- bi용 sql(OLAP)
-- 시계열성이 많다. 

use adventureworks;

select orderdate, count(*), sum(subtotal), avg(subtotal)
from salesorderheader
group by orderdate
order by orderdate;

-- #이동평균을 사용한 날짜별 추이보기
-- #날짜별 매출과 7일 이동평균을 집계하는 함수alter
select orderdate
, sum(subtotal) as dailytotal
-- 최근 최대 7일동안의 평균 계산하기
, avg(sum(subtotal)) over(order by orderdate rows between 6 preceding and current row) as 7day_avg,
-- 최근 최대 7일동안의 평균 확실하게 계산히기 (즉 7개가 모여야만 출력)
 case
	when 7=count(*)  over(order by orderdate rows between 6 preceding and current row) 
    then 
    avg(sum(subtotal)) over(order by orderdate rows between 6 preceding and current row) 
    end 
    as 7day_avg_strict
From SalesOrderHeader
group by orderdate;


-- z 차트를 만들기 위한 쿼리
-- 월 단위 매출구하기
select orderdate, substring(orderdate, 1, 7) as y_mon, 
sum(subtotal) as total_amount,
sum(sum(subtotal)) over(partition by substring(orderdate, 1, 7) order by orderdate rows unbounded preceding) as agg_amount 
# 월별로 합을 구해줘라 
# rows 행
# UNBOUNDED PRECEEDING은 첫번째 행을 윈도우 함수의 시작점으로,
# UNBOUNDED FOLLOWING은 마지막 행을 윈도우 함수의 끝점으로 한다
# 참고 - https://blog.naver.com/tbc_windy/222226578302
from SalesOrderHeader
group by orderdate;

# 위 함수를 뜯어보기위해서 test한 문장들임...
select orderdate
, substring(orderdate,1,7) as y_mon # orderdate 에서 1번째부터, 7번쨰까찌 가져와라 
, sum(subtotal) as total_amount
, sum(sum(subtotal)) 
  over(order by orderdate rows unbounded preceding)
	as agg_amount1
, sum(sum(subtotal)) 
  over(order by orderdate)
	as agg_amount2    
, sum(sum(subtotal)) 
  over(partition by substring(orderdate,1,7) order by orderdate rows unbounded preceding) 
	as agg_amount3
, sum(sum(subtotal)) 
  over(partition by substring(orderdate,1,7) order by orderdate ) #의미를 몰겠네 rows unbounded preceding
	as agg_amount4    
from SalesOrderHeader
group by orderdate
order by orderdate;


-- 임시테이블 활용하기
with 
daily_purchase as
(
	select orderdate, 
    substring(orderdate, 1, 4) as year,
	substring(orderdate, 6, 2) as month,
    substring(orderdate, 9, 2) as day,
    sum(subtotal) as subtotal1 
	from salesorderheader
	group by orderdate
)
select * from daily_purchase;


with
daily_purchase as
(
	select orderdate
	, substring(orderdate, 1, 4) as year
    , substring(orderdate, 6, 2) as month
    , substring(orderdate, 9, 2) as day
    , sum(subtotal) as subtotal
	from salesorderheader
	group by orderdate
)
SELECT
	orderdate
    , substring(orderdate,1,7) as YearMonth
    , sum(Subtotal) as total_amount
    , sum(Sum(subtotal)) 
      OVER( Partition by substring(orderdate, 1,7) Order by orderdate 
            Rows Unbounded Preceding)
    as cum_amount
from daily_purchase 
group by Orderdate
order by orderdate;


# 월별 매출과 작년대비를 계산하는 쿼리
with
daily_purchas as (
select
	orderdate
    , substring(orderdate, 1, 4) as year
    , substring(orderdate, 6, 2) as month
    , substring(orderdate, 9, 2) as day
    , sum(subtotal) as subtotal
from salesorderheader
group by orderdate
)
select
	month,
    sum(case year when '2002' then subtotal end) as amount_2002 ,
    sum(case year when '2003' then subtotal end) as amount_2003 ,
	100* sum(case year when '2003' then subtotal end) / sum(case year when '2002' then subtotal end) as rate
from daily_purchas
group by month
order by month;


-- z 차트로 업적의 추이 확인하기
WITH
daily_purchase AS (
SELECT
	orderdate
    , substring(orderdate, 1, 4) as year
    , substring(orderdate, 6, 2) as month
    , substring(orderdate, 9, 2) as day
    , sum(subtotal) as subtotal
FROM SalesOrderHeader
GROUP BY orderdate
)
# 임시 테이블 또 만들떄는 , 들어감
, monthly_purchase AS (
SELECT
	year
    ,month
    ,sum(subtotal) as amount
FROM daily_purchase
GROUP BY year, month
)
# 임시 테이블 또 만들떄는 , 들어감
, calc_index AS (
SELECT 
	year
    , month
    , amount
    -- 2002년도 누계 매출 집계하기
    , sum( CASE 
				when year='2002' 
                then amount 
		end ) 	OVER( Order by year, month rows unbounded preceding)
        as cum_amount
	, sum(amount)
		OVER( Order by year, month rows between 11 preceding and current row)
        as last_12_month_sum
FROM
    monthly_purchase
    Order by year, month
)
SELECT 
	concat(year,'-',month)  
    , amount
	, cum_amount
	, last_12_month_sum
from calc_index
where year ='2002'
order by concat(year,'-',month)
