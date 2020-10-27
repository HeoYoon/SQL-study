
/** 로그 최근일자 , 사용자별 등록일의 다음날을 계산하는 쿼리*/
with ACTION_LOG_WITH_MST_USERS as (
	select U.USER_ID
	     , U.REGISTER_DATE
	     , CAST(A.STAMP as DATE) as action_DATE
	     , MAX(cast(A.STAMP as DATE)) OVER() as LATEST_DATE
	     ,CAST(U.REGISTER_DATE::DATE + '1 day'::interval as date) as next_day_1
	     from mst_users as u
	     left outer join
	     action_log as a
	     on u.user_id = a.user_id

)
select * 
from ACTION_LOG_WITH_MST_USERS
order by register_date;

user_id|register_date|action_date|latest_date|next_day_1|
-------|-------------|-----------|-----------|----------|
U002   |2016-10-01   | 2016-10-01| 2016-10-20|2016-10-02|
U001   |2016-10-01   | 2016-10-01| 2016-10-20|2016-10-02|
U001   |2016-10-01   | 2016-10-01| 2016-10-20|2016-10-02| 
U001   |2016-10-01   | 2016-10-05| 2016-10-20|2016-10-02|
U001   |2016-10-01   | 2016-10-05| 2016-10-20|2016-10-02|
U001   |2016-10-01   | 2016-10-05| 2016-10-20|2016-10-02|
U001   |2016-10-01   | 2016-10-20| 2016-10-20|2016-10-02|
U001   |2016-10-01   | 2016-10-20| 2016-10-20|2016-10-02|
U001   |2016-10-01   | 2016-10-20| 2016-10-20|2016-10-02|
U002   |2016-10-01   | 2016-10-01| 2016-10-20|2016-10-02|
U001   |2016-10-01   | 2016-10-01| 2016-10-20|2016-10-02|
U002   |2016-10-01   | 2016-10-01| 2016-10-20|2016-10-02|
U002   |2016-10-01   | 2016-10-02| 2016-10-20|2016-10-02|
U002   |2016-10-01   | 2016-10-02| 2016-10-20|2016-10-02|
U018   |2016-10-01   |           | 2016-10-20|2016-10-02|
U008   |2016-10-01   |           | 2016-10-20|2016-10-02|
U003   |2016-10-01   |           | 2016-10-20|2016-10-02|
U005   |2016-10-01   |           | 2016-10-20|2016-10-02|
U012   |2016-10-01   |           | 2016-10-20|2016-10-02|
U014   |2016-10-01   |           | 2016-10-20|2016-10-02|
U010   |2016-10-01   |           | 2016-10-20|2016-10-02|
U015   |2016-10-01   |           | 2016-10-20|2016-10-02|
U017   |2016-10-01   |           | 2016-10-20|2016-10-02|
U004   |2016-10-01   |           | 2016-10-20|2016-10-02|
U009   |2016-10-01   |           | 2016-10-20|2016-10-02|
U016   |2016-10-01   |           | 2016-10-20|2016-10-02|
U011   |2016-10-01   |           | 2016-10-20|2016-10-02|
U007   |2016-10-01   |           | 2016-10-20|2016-10-02|
U006   |2016-10-01   |           | 2016-10-20|2016-10-02|
U013   |2016-10-01   |           | 2016-10-20|2016-10-02|
U019   |2016-10-01   |           | 2016-10-20|2016-10-02|
U025   |2016-10-02   |           | 2016-10-20|2016-10-03|
U023   |2016-10-02   |           | 2016-10-20|2016-10-03|
U027   |2016-10-02   |           | 2016-10-20|2016-10-03|
U029   |2016-10-02   |           | 2016-10-20|2016-10-03|
U021   |2016-10-02   |           | 2016-10-20|2016-10-03|
U020   |2016-10-02   |           | 2016-10-20|2016-10-03|
U026   |2016-10-02   |           | 2016-10-20|2016-10-03|
U028   |2016-10-02   |           | 2016-10-20|2016-10-03|
U024   |2016-10-02   |           | 2016-10-20|2016-10-03|
U022   |2016-10-02   |           | 2016-10-20|2016-10-03|
U030   |2016-10-02   |           | 2016-10-20|2016-10-03|


/** 12-5 사용자의 액션플래그를 계산하는 쿼리 */

with action_log_with_mst_users as (
		select U.USER_ID
	     , U.REGISTER_DATE
	     , CAST(A.STAMP as DATE) as action_DATE
	     , MAX(cast(A.STAMP as DATE)) OVER() as LATEST_DATE
	     ,CAST(U.REGISTER_DATE::DATE + '1 day'::interval as date) as next_day_1
	     from mst_users as u
	     left outer join
	     action_log as a
	     on u.user_id = a.user_id
)
,    user_action_flag as (

	 select user_id
		 , register_date
		 , sign(sum(case 
		            when next_day_1 <= latest_date 
		            then case 
		                 when next_day_1 = action_date 
		                 then 1 
		                 else 0 
		                 end
		            end)
		        ) as next_1day_action
	  from action_log_with_mst_users 
	  group by user_id, register_date
	  )

select * from user_action_flag
order by register_date , user_id;

user_id|register_date|next_1day_action|
-------|-------------|----------------|
U001   |2016-10-01   |             0.0|
U002   |2016-10-01   |             1.0|
U003   |2016-10-01   |             0.0|
U004   |2016-10-01   |             0.0|
U005   |2016-10-01   |             0.0|
U006   |2016-10-01   |             0.0|
U007   |2016-10-01   |             0.0|
U008   |2016-10-01   |             0.0|
U009   |2016-10-01   |             0.0|
U010   |2016-10-01   |             0.0|
U011   |2016-10-01   |             0.0|
U012   |2016-10-01   |             0.0|
U013   |2016-10-01   |             0.0|
U014   |2016-10-01   |             0.0|
U015   |2016-10-01   |             0.0|
U016   |2016-10-01   |             0.0|
U017   |2016-10-01   |             0.0|
U018   |2016-10-01   |             0.0|
U019   |2016-10-01   |             0.0|
U020   |2016-10-02   |             0.0|
U021   |2016-10-02   |             0.0|
U022   |2016-10-02   |             0.0|
U023   |2016-10-02   |             0.0|
U024   |2016-10-02   |             0.0|
U025   |2016-10-02   |             0.0|
U026   |2016-10-02   |             0.0|
U027   |2016-10-02   |             0.0|
U028   |2016-10-02   |             0.0|
U029   |2016-10-02   |             0.0|
U030   |2016-10-02   |             0.0|

/*12-6 다음날 지속률을 계산하는 쿼리*/
with action_log_with_mst_users as (
		select U.USER_ID
	     , U.REGISTER_DATE
	     , CAST(A.STAMP as DATE) as action_DATE
	     , MAX(cast(A.STAMP as DATE)) OVER() as LATEST_DATE
	     ,CAST(U.REGISTER_DATE::DATE + '1 day'::interval as date) as next_day_1
	     from mst_users as u
	     left outer join
	     action_log as a
	     on u.user_id = a.user_id
)
,    user_action_flag as (

	 select user_id
		 , register_date
		 , sign(sum(case 
		            when next_day_1 <= latest_date 
		            then case 
		                 when next_day_1 = action_date 
		                 then 1 
		                 else 0 
		                 end
		            end)
		        ) as next_1day_action
	  from action_log_with_mst_users 
	  group by user_id, register_date
	  )
	select register_date
     , avg(100.0 * next_1day_action) as repeat_rate_1_day
     from user_action_flag
     group by register_date 
     order by register_date;
     
    
register_date|repeat_rate_1_day |
-------------|------------------|
2016-10-01   |5.2631578947368425|
2016-10-02   |               0.0|

/* 12-7 지속률 지표를 관리하는 마스터 테이블을 작성하는 쿼리*/

with REPEAT_INTERVAL(INDEX_NAME , INTERVAL_DATE) as (
	values
	 ('01 DAY REPEAT', 1)
	 ,('02 DAY REPEAT', 2)
	 ,('03 DAY REPEAT', 3)
	 ,('04 DAY REPEAT', 4)
	 ,('05 DAY REPEAT', 5)
	 ,('06 DAY REPEAT', 6)
	 ,('07 DAY REPEAT', 7)
	 )
	 select * from REPEAT_INTERVAL
	 order by INDEX_NAME;
	
 /*12-8 지속률을 세로 기반으로 집계하는 쿼리*/
with REPEAT_INTERVAL(INDEX_NAME , INTERVAL_DATE) as (
	values
	 ('01 DAY REPEAT', 1)
	 ,('02 DAY REPEAT', 2)
	 ,('03 DAY REPEAT', 3)
	 ,('04 DAY REPEAT', 4)
	 ,('05 DAY REPEAT', 5)
	 ,('06 DAY REPEAT', 6)
	 ,('07 DAY REPEAT', 7)
	 )
, action_log_with_index_date as (
	select U.USER_ID
	     , U.REGISTER_DATE
	     , CAST(A.STAMP as DATE) as ACTION_DATE
	     , MAX(cast(A.STAMP as DATE )) OVER() as LATEST_DATE
	     , R.INDEX_NAME
	     , CAST(cast(U.REGISTER_DATE as DATE) + interval '1 DAY' * R.INTERVAL_DATE as DATE) as INDEX_DATE
	     from mst_users AS U left outer join action_log A 
	     on U.USER_ID = A.USER_ID
	     cross join REPEAT_INTERVAL as R
)
, USER_ACTION_FLAG as (
		select USER_ID
		     , REGISTER_DATE
		     , INDEX_NAME
		      ,SIGN(SUM(case when INDEX_DATE <= LATEST_DATE 
		      	 			 then case when INDEX_DATE = ACTION_DATE 
		      	 			           then 1 
		      	 			           else 0 
		      	 			           end
		      	 			 end
		      	 	    )
		      	 	) as INDEX_DATE_ACTION
		      from ACTION_LOG_WITH_INDEX_DATE
		      group by USER_ID,REGISTER_DATE,INDEX_NAME,INDEX_DATE
   )
   SELECT REGISTER_DATE
        , INDEX_NAME
        , AVG(100.0 * INDEX_DATE_ACTION) as REPEAT_RATE
        from USER_ACTION_FLAG
        group by REGISTER_DATE, INDEX_NAME
        order by REGISTER_DATE, INDEX_NAME;
		
)

register_date|index_name   |repeat_rate       |
-------------|-------------|------------------|
2016-10-01   |01 DAY REPEAT|5.2631578947368425|
2016-10-01   |02 DAY REPEAT|               0.0|
2016-10-01   |03 DAY REPEAT|               0.0|
2016-10-01   |04 DAY REPEAT|5.2631578947368425|
2016-10-01   |05 DAY REPEAT|               0.0|
2016-10-01   |06 DAY REPEAT|               0.0|
2016-10-01   |07 DAY REPEAT|               0.0|
2016-10-02   |01 DAY REPEAT|               0.0|
2016-10-02   |02 DAY REPEAT|               0.0|
2016-10-02   |03 DAY REPEAT|               0.0|
2016-10-02   |04 DAY REPEAT|               0.0|
2016-10-02   |05 DAY REPEAT|               0.0|
2016-10-02   |06 DAY REPEAT|               0.0|
2016-10-02   |07 DAY REPEAT|               0.0|


/* 12-9 정착률 지표를 관리하는 마스터 테이블을 작성하는 쿼리*/
with REPEAT_INTERVAL(INDEX_NAME , INTERVAL_BEGIN_DATE , INTERVAL_END_DATE) as (
	values
	 ('07 DAY REPEAT', 1 , 7)
	 ,('14 DAY REPEAT', 8 , 14)
	 ,('21 DAY REPEAT', 15 , 21)
	 ,('28 DAY REPEAT', 22 , 28)
)

select * from REPEAT_INTERVAL
order by INDEX_NAME;

/* 12-10 정착률을 계산하는 쿼리*/
with REPEAT_INTERVAL(INDEX_NAME , INTERVAL_BEGIN_DATE , INTERVAL_END_DATE) as (
	values
	 ('07 DAY REPEAT', 1 , 7)
	 ,('14 DAY REPEAT', 8 , 14)
	 ,('21 DAY REPEAT', 15 , 21)
	 ,('28 DAY REPEAT', 22 , 28)
)

, action_LOG_WITH_INDEX_DATE as (
	select U.USER_ID
	     , U.REGISTER_DATE
	     , CAST(A.STAMP as DATE) as ACTION_DATE
	     , MAX(cast(A.STAMP as DATE )) OVER() as LATEST_DATE
	     , R.INDEX_NAME
	     
	     -- 지표의 대상기간 시작일과 종료일 계산하기
	     , CAST(U.REGISTER_DATE::DATE + '1 DAY'::interval * R.INTERVAL_BEGIN_DATE as DATE) as INDEX_BEGIN_DATE
	     , CAST(U.REGISTER_DATE::DATE + '1 DAY'::interval * R.INTERVAL_END_DATE as DATE) as INDEX_END_DATE
	     from mst_users U 
	     left outer join
	     action_log A
	     on U.user_id = A.user_id 
	     cross join REPEAT_INTERVAL as R
)

, USER_ACTION_FLAG as (
			select USER_ID
		     , REGISTER_DATE
		     , INDEX_NAME
		      ,SIGN(SUM(case when INDEX_END_DATE <= LATEST_DATE 
		      	 			 then case when ACTION_DATE between INDEX_BEGIN_DATE and INDEX_END_DATE 
		      	 			           then 1 
		      	 			           else 0 
		      	 			           end
		      	 			 end
		      	 	    )
		      	 	) as INDEX_DATE_ACTION
		      from ACTION_LOG_WITH_INDEX_DATE
		      group by USER_ID,REGISTER_DATE,INDEX_NAME,INDEX_BEGIN_DATE,INDEX_END_DATE
   )
 select REGISTER_DATE
      , INDEX_NAME
      , AVG(100.0 * INDEX_DATE_ACTION) as INDEX_RATE
      from USER_ACTION_FLAG
      group by REGISTER_DATE , INDEX_NAME
      order by REGISTER_DATE , INDEX_NAME;
     
     
register_date|index_name   |index_rate        |
-------------|-------------|------------------|
2016-10-01   |07 DAY REPEAT|10.526315789473685|
2016-10-01   |14 DAY REPEAT|               0.0|
2016-10-01   |21 DAY REPEAT|                  |
2016-10-01   |28 DAY REPEAT|                  |
2016-10-02   |07 DAY REPEAT|               0.0|
2016-10-02   |14 DAY REPEAT|               0.0|
2016-10-02   |21 DAY REPEAT|                  |
2016-10-02   |28 DAY REPEAT|                  |

/* 12-11 지속률 지표를 관리하는 마스터 테이블을 정착률 형식으로 수정한 쿼리 */

with REPEAT_INTERVAL(INDEX_NAME , INTERVAL_BEGIN_DATE , INTERVAL_END_DATE) as (
	values
	  ('01 DAY REPEAT', 1 , 1)
	 ,('02 DAY REPEAT', 2 , 2)
	 ,('03 DAY REPEAT', 3 , 3)
	 ,('04 DAY REPEAT', 4 , 4)
	 ,('05 DAY REPEAT', 5 , 5)
	 ,('06 DAY REPEAT', 6 , 6)
	 ,('07 DAY REPEAT', 7 , 7)
	 ,('07 DAY REPEAT', 1 , 7)
	 ,('14 DAY REPEAT', 8 , 14)
	 ,('21 DAY REPEAT', 15 , 21)
	 ,('28 DAY REPEAT', 22 , 28)
)
 select * 
 from REPEAT_INTERVAL
 order by INDEX_NAME

 /* 12-12 N일 지속률을 집계하는 쿼리*/
 with REPEAT_INTERVAL(INDEX_NAME , INTERVAL_BEGIN_DATE , INTERVAL_END_DATE) as (
	values
	  ('01 DAY REPEAT', 1 , 1)
	 ,('02 DAY REPEAT', 2 , 2)
	 ,('03 DAY REPEAT', 3 , 3)
	 ,('04 DAY REPEAT', 4 , 4)
	 ,('05 DAY REPEAT', 5 , 5)
	 ,('06 DAY REPEAT', 6 , 6)
	 ,('07 DAY REPEAT', 7 , 7)
	 ,('07 DAY retention', 1 , 7)
	 ,('14 DAY retention', 8 , 14)
	 ,('21 DAY retention', 15 , 21)
	 ,('28 DAY retention', 22 , 28)
)
 
, action_LOG_WITH_INDEX_DATE as (
	SELECT U.USER_ID
	     , U.REGISTER_DATE
	     --액션의 날짜와 로그 전체의 최신 날짜 자료형으로 변환하기
	     , CAST(A.STAMP as DATE) as ACTION_DATE
	     , MAX(cast(A.STAMP as DATE )) OVER() as LATEST_DATE
	     , R.INDEX_NAME
	     
	     -- 지표의 대상기간 시작일과 종료일 계산하기
	     , CAST(U.REGISTER_DATE::DATE + '1 DAY'::interval * R.INTERVAL_BEGIN_DATE as DATE) as INDEX_BEGIN_DATE
	     , CAST(U.REGISTER_DATE::DATE + '1 DAY'::interval * R.INTERVAL_END_DATE as DATE) as INDEX_END_DATE
	     FROM mst_users U 
	     LEFT OUTER JOIN
	     action_log A
	     ON U.user_id = A.user_id 
	     CROSS JOIN REPEAT_INTERVAL as R
)

, USER_ACTION_FLAG as (
			select USER_ID
		     , REGISTER_DATE
		     , INDEX_NAME
		      ,SIGN(SUM(case when INDEX_END_DATE <= LATEST_DATE 
		      	 			 then case when ACTION_DATE between INDEX_BEGIN_DATE and INDEX_END_DATE 
		      	 			           then 1 
		      	 			           else 0 
		      	 			           end
		      	 			 end
		      	 	    )
		      	 	) as INDEX_DATE_ACTION
		      from ACTION_LOG_WITH_INDEX_DATE
		      group by USER_ID,REGISTER_DATE,INDEX_NAME,INDEX_BEGIN_DATE,INDEX_END_DATE
   )
   
   select INDEX_NAME
        , AVG(100.0 * INDEX_DATE_ACTION) as REPEAT_DATE
        from USER_ACTION_FLAG
        group by INDEX_NAME
        order by INDEX_NAME;