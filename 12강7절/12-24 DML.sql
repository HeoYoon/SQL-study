
/*
 *  리피트 사용자를 3가지로 분류하기
 *  리피트 사용자는 이전 달에도 사용한 사용자라고 정의합니다. 
 *  그런데 이전 달의 사용자 상태에 따라 추가로 리피트 사용자를 다음 3가지로 분류할 수 있습니다.
 *  
 *  1.신규 리피트 사용자 : 이전 달에는 신규 사용자로 분류되었으며, 이번 달에도 사용한 사용자
 *  2.기존 리피트 사용자 : 이전 달도 리피트 사용자로 분류되었으며, 이번 달에도 사용한 사용자
 *  3.컴백 리피트 사용자 : 이전 달에 컴백 사용자로 분류되었으며, 이번 달에도 사용한 사용자
 * 
 * */

코드 12-24 리피트 사용자를 세분화해서 집계하는 쿼리

 with monthly_user_action as (
   --월별 사용자 액션 집약하기
    select distinct 
    u.user_id
    , substring(u.register_date , 1, 7) as register_month
    , substring(l.stamp , 1, 7) as action_month
    , substring(cast(l.stamp::date - interval '1 month' as text) , 1, 7) as ACTION_MONTH_PRIV 
  
  from mst_users as U
  inner join action_log as L
  on U.user_id = L.user_id 
  ) 
  , monthly_user_with_type AS(
  								select action_month
							  	     , user_id
							  	     , case when register_month = action_month 
							  	     			then 'new_user'
							  	     		when action_month_priv = LAG(action_month) OVER(partition by user_id order by action_month)
							  	     			then 'repeat_user'
							  	     			else 'comback_user'
							  	     			end as c  						
							  	     , action_month_priv
							  	    
							  	    from monthly_user_action
  )
  , monthly_users as (select M1.action_month
  							,count(m1.user_id) as mau
  							,count(case when m1.c = 'new_user' then 1 end) as new_users
  							,count(case when m1.c = 'repeat_user' then 1 end) as repeat_users
  							,count(case when m1.c = 'comback_user' then 1 end) as comback_users
  							
  							, count( case when m1.c = 'repeat_user' and m0.c = 'new_user' then 1 end) as new_repeat_users
  							, count( case when m1.c = 'repeat_user' and m0.c = 'repeat_user' then 1 end) as continuous_repeat_users
  							, count( case when m1.c = 'repeat_user' and m0.c = 'comback_user' then 1 end) as come_back_repeat_users
  							
  						from monthly_user_with_type as m1
  						left outer join monthly_user_with_type as m0
  						on m1.user_id = m0.user_id
  						and m1.action_month_priv = m0.action_month
  						group by m1.action_month
  						)
  						
  						
  						select * from monthly_users
  						order by action_month;
  							
  							
  							
  
  )
  
  					