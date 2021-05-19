코드 12-23 /*방문 빈도를 기반으로 사용자 속성을 정의하고 집계하기

* 방문빈도에 따라 사용자를 분류하고 내역을 집계하는 방법
* 
**/


# MAU = 특정 월에 서비스를 사용한 사용자 수 (Monthly Active Users)
 서비스 사용자의 구성을 더 자세하게 파악하려면 MAU를 3개의 속성으로 나누어 분석해야함.
 
 1.신규 사용자 : 이 달에 등록한 신규 사용자
 2.리피트 사용자 : 이전 달에도 사용했던 사용자
 3.컴백 사용자 : 이번 달의 신규 등록자가 아니고, 이전 달에도 사용하지 않았던 , 한동한 사용하지 않았던 휴먼유저
 
 
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
  ) ,monthly_user_with_type AS(
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
  
  select action_month
  , Count(user_id) as mau
  , COUNT(case when c = 'new user' then 1 end) as new_users
  , COUNT(case when c = 'repeat_user' then 1 end) as repeat_user
  , COUNT(case when c = 'comback_user' then 1 end) as comback_user
  from monthly_user_with_type
  group by action_month 
  order by action_month
  
  
  
  
  
  