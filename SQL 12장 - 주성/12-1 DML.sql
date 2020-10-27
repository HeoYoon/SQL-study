
/******************** 12-1 등록 수의 추이와 경향 보기 ********************/

	/*날짜별 등록 수의 추이를 집계하는 쿼리*/
SELECT REGISTER_DATE
     , COUNT(USER_ID) AS COUNT_REGISTER_DATE
     FROM MST_USERS 
     GROUP BY REGISTER_DATE  
     ORDER BY REGISTER_DATE;
    
register_date|count_register_date|
-------------|-------------------|
2016-10-01   |                  3|
2016-10-05   |                  2|
2016-10-10   |                  3|
2016-10-15   |                  1|
2016-10-16   |                  1|
2016-10-18   |                  2|
2016-10-20   |                  1|
2016-10-25   |                  1|
2016-11-01   |                  5|
2016-11-03   |                  3|
2016-11-04   |                  1|
2016-11-05   |                  2|
2016-11-10   |                  2|
2016-11-15   |                  1|
2016-11-28   |                  2|    
     
/*매달 등록 수와 전월비를 계산하는 쿼리*/
     
with MST_USERS_YEARMONTH as (

	select *
		 , SUBSTR(REGISTER_DATE , 1, 7) as YEAR_MONTH
     from mst_users
)    

select YEAR_MONTH
 	 , COUNT(USER_ID) as REGISTER_COUNT
 	 , LAG(COUNT(USER_ID)) OVER(order by YEAR_MONTH) as LAST_MONTH_COUNT
 	 , 1.0 * COUNT(USER_ID) / LAG(COUNT(USER_ID)) OVER(order by YEAR_MONTH) as MONTH_OVER_MONTH_RATIO
  from MST_USERS_YEARMONTH
  group by YEAR_MONTH;
  
 year_month|register_count|last_month_count|month_over_month_ratio|
----------|--------------|----------------|----------------------|
2016-10   |            14|                |                      |
2016-11   |            16|              14|    1.1428571428571429|


/**디바스들의 등록 수를 집계하는 쿼리*/
     
with MST_USERS_YEARMONTH as (

	select *
		 , SUBSTR(REGISTER_DATE , 1, 7) as YEAR_MONTH
     from mst_users
)    
select year_month
    , count(user_id) as register_count
    , count(distinct case when register_device = 'pc' then user_id end) as register_pc
    , count(distinct case when register_device = 'sp' then user_id end) as register_sp
    , count(distinct case when register_device = 'app' then user_id end) as register_pc
    from MST_USERS_YEARMONTH
    group by year_month ;
    

year_month|register_count|register_pc|register_sp|register_pc|
----------|--------------|-----------|-----------|-----------|
2016-10   |            14|          7|          4|          3|
2016-11   |            16|          4|          4|          8|




