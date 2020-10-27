/* 12-13 모든 사용자의 액션의 조합을 도출하는 쿼리*/

with repeat_interval(index_name , INTERVAL_BEGIN_DATE , INTERVAL_END_DATE) as (
	values ('01 day repeat' , 1 , 1)
)

, action_log_with_index_date as (
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

, user_action_flag as (
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

, mst_actions as (

	select 'VIEW' as action
	union all select 'COMMENT' as action
	union all select 'FOLLOW' as action
	
)
, MST_USER_ACTIONS as (
	select U.USER_ID
	     , U.REGISTER_DATE
	     , A.action
	     from mst_users as U
	     cross join MST_ACTIONS as A
)

select * from MST_USER_ACTIONS
order by USER_ID, action;

/* 12-14  사용자의 액션 로그를 0,1의 플래그를 표현하는 쿼리 */

with repeat_interval(index_name , INTERVAL_BEGIN_DATE , INTERVAL_END_DATE) as (
	values ('01 day repeat' , 1 , 1)
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
		      -- 지표의 대상 기간에 액션을 했는지 플래그로 나타내기
		      ,SIGN(
		           -- 사용자 별로 대상 기간에 한 액션의 합계
		           SUM(
		            -- 대상 기간의 종료일이 로그의 최신 날짜 이전인지 확인
		            case when INDEX_END_DATE <= LATEST_DATE
		                     -- 지표의 대상 기간에 액션을 했다면 1 안했다면 0
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
, MST_ACTIONS as (

	select 'VIEW' as action
	union all select 'COMMENT' as action
	union all select 'FOLLOW' as action
	
)
, MST_USER_ACTIONS as (
	select U.USER_ID
	     , U.REGISTER_DATE
	     , A.action
	     from mst_users as U
	     cross join MST_ACTIONS as A
)
, REGISTER_ACTION_FLAG as (
	select distinct M.USER_ID
	     , M.REGISTER_DATE
	     , M.action
	     , case when A.action is not null then 1
	                                      else 0
	                                      end as DO_ACTION
         ,INDEX_NAME
         ,INDEX_DATE_ACTION
     from MST_USER_ACTIONS as M
     left join action_log as A
     on M.USER_ID = A.user_id 
     and CAST(M.REGISTER_DATE as DATE) = CAST(A.stamp as DATE)
     and M.action = A.action
     left join USER_ACTION_FLAG as F
     on M.USER_ID = F.USER_ID
     where F.INDEX_DATE_ACTION is not null 
)

select * from 
REGISTER_ACTION_FLAG
order by USER_ID , INDEX_NAME ,action;
     
/* 12-15 액션에 따른 지속률과 정착률을 집계하는 쿼리*/

with repeat_interval(index_name , INTERVAL_BEGIN_DATE , INTERVAL_END_DATE) as (
	values ('01 day repeat' , 1 , 1)
)
, action_LOG_WITH_INDEX_DATE as (
	select U.USER_ID
	     , U.REGISTER_DATE
	     , CAST(A.STAMP as DATE) as ACTION_DATE
	     , MAX(CAST(A.STAMP as DATE)) OVER() as LATEST_DATE
	     , R.INDEX_NAME
	     
	     -- 지표의 대상기간 시작일과 종료일 계산하기
	     , CAST(U.REGISTER_DATE::DATE + '1 DAY'::interval * R.INTERVAL_BEGIN_DATE as DATE) as INDEX_BEGIN_DATE
	     , CAST(U.REGISTER_DATE::DATE + '1 DAY'::interval * R.INTERVAL_END_DATE as DATE) as INDEX_END_DATE
	     from mst_users U 
	     left outer join
	     ACTION_LOG A
	     ON U.USER_ID = A.USER_ID 
	     CROSS JOIN REPEAT_INTERVAL AS R
)


, USER_ACTION_FLAG as (
			select USER_ID
			     , REGISTER_DATE
			     , INDEX_NAME
			      -- 지표의 대상 기간에 액션을 했는지 플래그로 나타내기
			     ,SIGN(
	             	 -- 사용자 별로 대상 기간에 한 액션의 합계
			           SUM(
			            -- 대상 기간의 종료일이 로그의 최신 날짜 이전인지 확인
			            CASE WHEN INDEX_END_DATE <= LATEST_DATE
			                     -- 지표의 대상 기간에 액션을 했다면 1 안했다면 0
			      	 			 THEN CASE WHEN ACTION_DATE BETWEEN INDEX_BEGIN_DATE AND INDEX_END_DATE 
			      	 			           THEN 1 
			      	 			           ELSE 0 
			      	 			           END
			      	 			 END
			      	 	)
			      	 ) as INDEX_DATE_ACTION
			      FROM ACTION_LOG_WITH_INDEX_DATE
			      GROUP BY USER_ID,REGISTER_DATE,INDEX_NAME,INDEX_BEGIN_DATE,INDEX_END_DATE
  )
, MST_ACTIONS as (

	select 'VIEW' as action
	union all select 'COMMENT' as action
	union all select 'FOLLOW' as action
	
)
, MST_USER_ACTIONS as (
	select U.USER_ID
	     , U.REGISTER_DATE
	     , A.action
	     from mst_users as U
	     cross join MST_ACTIONS as A
)
, REGISTER_ACTION_FLAG as (
	SELECT DISTINCT M.USER_ID
	     , M.REGISTER_DATE
	     , M.ACTION
	     , CASE WHEN A.ACTION IS NOT NULL THEN 1
	                                      ELSE 0
	                                      END AS DO_ACTION
         , INDEX_NAME
         , INDEX_DATE_ACTION
     FROM MST_USER_ACTIONS AS M
     LEFT JOIN ACTION_LOG AS A
     ON M.USER_ID = A.USER_ID 
     AND CAST(M.REGISTER_DATE AS DATE) = CAST(A.STAMP AS DATE)
     AND M.ACTION = A.ACTION
     LEFT JOIN USER_ACTION_FLAG AS F
     ON M.USER_ID = F.USER_ID
     WHERE F.INDEX_DATE_ACTION IS NOT NULL 
)

select action 
      , COUNT(1) USERS
      , AVG(100.0 * DO_ACTION) as USAGE_RATE
      , INDEX_NAME
      , AVG(case DO_ACTION when 1 then 100.0 * INDEX_DATE_ACTION END) as IDX_RATE
      , AVG(case DO_ACTION when 0 then 100.0 * INDEX_DATE_ACTION END) as NO_ACTION_IDX_RATE
      from REGISTER_ACTION_FLAG
      group by INDEX_NAME , action
      order by INDEX_NAME , action;
     
     
     

